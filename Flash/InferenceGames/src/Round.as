// this class holds information describing the current round.

package
{
	import common.DebugUtilities;
	import common.MathUtilities;
	
	import embedded_asset_classes.BotPlayerSWC;
	import embedded_asset_classes.ControlsSWC;
	import embedded_asset_classes.PlayerAPI;
	import embedded_asset_classes.UserPlayerSWC;
	
	import flash.utils.getTimer;
	
	public class Round
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		public static const WINNING_SCORE:int = 6; 	// how many points a player needs to win the game.
		
		public static var currentRound:Round; // the round object we're currently playing.
		
		public static const kLevelSettings:Array = [
			{ iqr:7,	/*sd:5.2,*/	interval:1	}, // level 1
			{ iqr:7,	/*sd:5.2,*/		interval:4	},
			{ iqr:7,	/*sd:5.2,*/		interval:2	},
			{ iqr:14,	/*sd:10,*/		interval:2	},
			{ iqr:27,	/*sd:20,*/		interval:2	},
			{ iqr:20,	/*sd:15,*/		interval:2	} // level 6
		];
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		private static var _roundID:int = 0;		// ID number for this round
		
		private var _samples:Array; 	// array of numeric values generated for this round
		private var _sampleMedian:Number;		
		private var _median:int; 		// population median
		private var _interval:Number;
		private var _IQR:Number; 		// population inter-quartile range	
		
		private var _guess:Number = 0;	// the auto-generated guess, based on the sample size.
										// currently, the user & the bot use the auto-generated guess.
		private var _accuracy:int; 		// the chances of guessing correctly at the current sample size.
		
		private var _isWon:Boolean = false; //whether or not this round has been won, calculated when we call for the results string
		private var _lastBuzzer:PlayerAPI; // the player who buzzed in this round.
		
		// constructor
		public function Round( whichLevel:int ) {
			DebugUtilities.assert( whichLevel >= 1 && whichLevel <= kLevelSettings.length, "whichLevel out of range" );
			
			Round.currentRound = this;
			
			++_roundID;
			_interval 	= kLevelSettings[ whichLevel-1 ].interval;
			_IQR 		= kLevelSettings[ whichLevel-1 ].iqr;
			_median 	= InferenceGames.instance.randomizer.uniformNtoM( 0, 100 );
			_samples	= new Array;	// forget about old samples
			_sampleMedian = 0;
			
			trace("Median: ", _median);
			
			ControlsSWC.CONTROLS.interval = _interval; // update the GUI.
			ControlsSWC.CONTROLS.IQR = _IQR; // update the GUI.
			
			ExpertAI.newRound( MathUtilities.IQR_to_SD(_IQR), _interval); // prepare the AI for the new round.
		}
		
		// a point of data has been added.
		public function addData():void {
			
			// generate random data value; note that mean and median are interchangable for an symmetrical normal curve.
			var value:int = InferenceGames.instance.randomizer.normalWithMeanIQR( _median, _IQR );
			_samples.push( value );
			_sampleMedian = MathUtilities.medianOfNumericArray( _samples ); // warning: _samples is sorted at this point.
						
			// push this point of data into an array that stores all data not yet evaluated.
			_dataArray.push( [_roundID, value ]);
			
			if(getTimer() - lastSendTime > SEND_TIME){
				lastSendTime = getTimer();
				InferenceGames.instance.sendEventData ( _dataArray );
				_dataArray = new Array();
				
				_accuracy = calculateAccuracy();
				ExpertAI.judgeData( _samples.length); // the expert judges the data, and may guess.
			}
		}
		
		public function get lastBuzzer():PlayerAPI{
			return _lastBuzzer;
		}
		
		public function set lastBuzzer(player:PlayerAPI):void{
			_lastBuzzer = player;
		}
		
		public function get roundID():int {
			return _roundID;
		}		
		
		public function get numDataSoFar():int {	// TO-DO: rename to numSamplesSoFar()
			return _samples.length;
		}
		
		public function get sampleMedian():Number{
			return _sampleMedian;
		}
		
		public function get interval():Number {
			return _interval;
		}
		
		public function get IQR():Number {
			return _IQR;
		}
		
		// get the automatically generated guess, based on the median of the sample data.
		public function get guess():Number {
			return _guess;
		}
		
		public function set guess( arg:Number):void{
			_guess = arg;
		}
		
		// get the accuracy of the current guess, based on the sample size:
		public function get accuracy():Number {
			return _accuracy;
		}
		
		public function get isWon():Boolean{
			return _isWon;
		}
		
		// true = win, false = lose
		public function calculateWinLose():void{
			// checking to see if the  round has been won, regardless of who stopped the clock
			if(_guess >= (_median-_interval)  && _guess <= (_median + _interval)){
				_isWon = true;
			}else{
				_isWon = false; 
			}
		}
		
		// get the result string showing who won or lost for this round
		public function getResultsString():String {
			calculateWinLose();
			// returning results string based on win/loss, and who last hit buzzer
			if( this.lastBuzzer == UserPlayerSWC.PLAYER ){
				return(_isWon ? "You were correct" : "You were incorrect"); 
			} else if( this.lastBuzzer == BotPlayerSWC.BOT ){
				return(_isWon ? "Expert was correct" : "Expert was incorrect" );
			} else {
				return("the lastBuzzer variable is not set to the player, or the bot");
			}
		}
		
		// Give points to the winner of the current round. 
		// This is called from the results screen, when it finishes animating.
		public function handlePoints():void{
			if(isWon){
				lastBuzzer.earnPoint(); // if the last buzzer was correct, he or she earns a point.
			} else {
				lastBuzzer.otherPlayer.earnPoint(); // otherwise, the opponent earns 2 points.
				lastBuzzer.otherPlayer.earnPoint();
			}
		}
		
		// auto-generate a guess based on the median of the current sample.
		public function calculateGuess():void {
			_guess = _sampleMedian; // Take the median of the data.
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private var _dataArray:Array = new Array(); // this array holds all the data that hasn't yet been pushed/evaluated.
		private var lastSendTime:Number = 0; // the time stamp of the last sent data point.
		private const SEND_TIME:int = 150; // how many miliseconds between basket emptyings.
																		// Whenever it ticks, the basket is emptied, and data is pushed to DG/analyzed by the expert.
		// generates an accuracy %, based on the sample size.
		private function calculateAccuracy():Number {
			return MathUtilities.calculateAreaUnderBellCurve( interval * 2, numDataSoFar, MathUtilities.IQR_to_SD(IQR)) * 100;
		}
	}
}