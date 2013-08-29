// this class holds information describing the current round.

package
{
	import common.DebugUtilities;
	import common.MathUtilities;
	
	import embedded_asset_classes.BotPlayerSWC;
	import embedded_asset_classes.ControlsSWC;
	import embedded_asset_classes.PlayerAPI;
	import embedded_asset_classes.UserPlayerSWC;
	
	public class Round
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		public static const WINNING_SCORE:int = 6; 	// how many points a player needs to win the game.
		public static const WIN_POINTS:int = 1; 	// how many points you get for guessing correctly.
		public static const MISS_POINTS:int = 2; 	// how many points the opponent gets when you miss.

		public static const IS_PLAYER:Boolean = true;
		public static const IS_BOT:Boolean = false;
		
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
		
		public var lastBuzzer:PlayerAPI; // the player who buzzed in this round.
		
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
			
			ControlsSWC.CONTROLS.interval = _interval; // update the GUI.
			ControlsSWC.CONTROLS.IQR = _IQR; // update the GUI.
			ControlsSWC.CONTROLS.currentSampleMedian = 0;
			
			ExpertAI.newRound( MathUtilities.IQR_to_SD(_IQR), _interval); // prepare the AI for the new round.
		}
		
		// a point of data has been added.
		public function addData( value:Number = 0):void {
			
			// generate random data value; note that mean and median are interchangable for an symmetrical normal curve.
			value = InferenceGames.instance.randomizer.normalWithMeanIQR( _median, _IQR );
			_samples.push( value );
			_sampleMedian = MathUtilities.medianOfNumericArray( _samples ); // warning: _samples is sorted at this point.
			
			// based on the data so far, calculate the best guess.			
			ControlsSWC.CONTROLS.currentSampleMedian = calculateGuess(); 
			_guess = calculateGuess();
			_accuracy = calculateAccuracy();
			trace( "count: ", numDataSoFar, " accuracy: ", _accuracy);
			
			InferenceGames.instance.sendEventData( [[ _roundID, value ]] );
			
			if(  _samples.length >= ExpertAI.guessNumSamples ){		// when the sample N goes above the expert's guessN, he guesses.
				InferenceGames.instance.hitBuzzer( IS_BOT);
			}
		}
		
		public function get roundID():int {
			return _roundID;
		}		
		
		public function get numDataSoFar():int {	// TO-DO: rename to numSamplesSoFar()
			return _samples.length;
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
		
		// get the accuracy of the current guess, based on the sample size:
		public function get accuracy():Number {
			return _accuracy;
		}
		
		public function get isWon():Boolean{
			return _isWon;
		}
		
		// true = win, false = lose
		public function calculateWinLose():void{
			// checking to see if the  game has been won, regardless of who stopped the clock
			if(_sampleMedian >= (_median-_interval)  && _sampleMedian <= (_median + _interval)){
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
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		// auto-generate a guess based on the median of the current sample.
		private function calculateGuess():Number {
			return _sampleMedian; // Take the median of the data.
		}
		
		// generates an accuracy %, based on the sample size.
		private function calculateAccuracy():Number {
			return MathUtilities.calculateAreaUnderBellCurve( interval * 2, numDataSoFar, MathUtilities.IQR_to_SD(IQR)) * 100;
		}
	}
}