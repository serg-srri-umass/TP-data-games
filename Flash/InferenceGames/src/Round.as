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
			{ iqr:7,	/*sd:5.2,*/	    interval:1	}, // level 1
			{ iqr:7,	/*sd:5.2,*/		interval:1	},
			{ iqr:7,	/*sd:5.2,*/		interval:"?"},
			{ iqr:"?",	/*sd:10,*/		interval:1	},
			{ iqr:"?",	/*sd:20,*/		interval:"?"},
			{ iqr:"?",	/*sd:15,*/		interval:"?"} // level 6
		];
		
		public static const kIntervalWidth:Array = [4, 2, 1, 4, 6, 10]; // variable interval widths for levels with ?
		
		public static const kIQR:Array = [7, 3, 1, 7, 9, 12]; // variable IQRs for levels with ?
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		private static var _roundID:int = 0;		// ID number for this round
		private static var _intervalIndex:int = -1; // inc'd each round to set next interval on level 3. Neg so first inc brings to 0.
		private static var _IQRIndex:int = -1; // inc'd each round to set next IQR on leve 4. Neg so first inc brings to 0.
		
		private var _samples:Array; 	// array of numeric values generated for this round
		private var _sampleMedian:Number;		
		private var _median:int; 		// population median
		private var _interval:Number;
		private var _IQR:Number; 		// population inter-quartile range	
		private var _chunkSize:int;
		private var _minNumChunks:int = 3;
		private var _maxNumChunks:int = 12;
		
		private var _guess:Number = 0;	// the auto-generated guess, based on the sample size.
										// currently, the user & the bot use the auto-generated guess.
		private var _accuracy:int; 		// the chances of guessing correctly at the current sample size.
		
		private var _isWon:Boolean = false; //whether or not this round has been won, calculated when we call for the results string
		private var _lastBuzzer:PlayerAPI; // the player who buzzed in this round.
		private var _level:int = 0; //level of this round
	
		// constructor
		public function Round( whichLevel:int ) {
			DebugUtilities.assert( whichLevel >= 1 && whichLevel <= kLevelSettings.length, "whichLevel out of range" );
			
			Round.currentRound = this;
			
			++_roundID;
			
			// setting IQR and Interval based on level
			switch(whichLevel){
				case 3:
					_intervalIndex = (_intervalIndex + 1) % kIntervalWidth.length; // next index in bounds
					_IQR = kLevelSettings[ whichLevel-1 ].iqr;
					_interval = kIntervalWidth[_intervalIndex];
					ControlsSWC.instance.interval = _interval; // update the GUI.
					ControlsSWC.instance.IQR = _IQR.toFixed(0); // update the GUI.
					break;
				case 4:
					_IQRIndex = (_IQRIndex + 1) % kIQR.length; // next index in bounds
					_interval = kLevelSettings[ whichLevel-1 ].interval;
					_IQR	  = kIQR[_IQRIndex];
					ControlsSWC.instance.interval = _interval; // update the GUI.
					ControlsSWC.instance.IQR = _IQR.toFixed(0); // update the GUI.
					break;
				case 5: 
					_intervalIndex = (_intervalIndex + 1) % kIntervalWidth.length; // next index in bounds
					_IQRIndex = (_IQRIndex + 1) % kIQR.length; // next index in bounds
					_interval = kIntervalWidth[_intervalIndex];
					_IQR	  = kIQR[_IQRIndex];
					ControlsSWC.instance.interval = _interval; // update the GUI.
					ControlsSWC.instance.IQR = _IQR.toFixed(0); // update the GUI.
					break;
				case 6:
					_intervalIndex = (_intervalIndex + 1) % kIntervalWidth.length; // next index in bounds
					_IQRIndex = (_IQRIndex + 1) % kIQR.length; // next index in bounds
					_interval = kIntervalWidth[_intervalIndex];
					_IQR	  = kIQR[_IQRIndex];
					ControlsSWC.instance.interval = _interval; // update the GUI.
					ControlsSWC.instance.IQR = "?"; // update the GUI.
					break;
				default:
					_interval 	= kLevelSettings[ whichLevel-1 ].interval;
					_IQR 		= kLevelSettings[ whichLevel-1 ].iqr;
					ControlsSWC.instance.interval = _interval; // update the GUI.
					ControlsSWC.instance.IQR = _IQR.toFixed(0); // update the GUI.
			}
			
			_median 	= InferenceGames.instance.randomizer.uniformNtoM( 0, 100 );
			_samples	= new Array; // forget about old samples
			_sampleMedian = 0;
			_level = whichLevel; 
			
			trace("Population Median for new round: ", _median);
			
			
			
			ExpertAI.newRound( MathUtilities.IQR_to_SD(_IQR), _interval); // prepare the AI for the new round.
		}
		
		// a point of data has been added.
		public function addData():void {
			
			// generate random data value; note that mean and median are interchangable for a symmetrical normal curve.
			var value:int = InferenceGames.instance.randomizer.normalWithMeanIQR( _median, _IQR );
			_samples.push( value );
			_sampleMedian = MathUtilities.medianOfNumericArray( _samples ); // warning: _samples is sorted at this point.
						
			// push this point of data into an array that stores all data not yet evaluated.
			_dataArray.push( [_roundID, value ]);
			
			if(true /*getTimer() - lastSendTime > SEND_TIME*/){
				lastSendTime = getTimer();
				InferenceGames.instance.sendEventData ( _dataArray );
				_dataArray = new Array();
				
				_accuracy = calculateAccuracy();
				ExpertAI.judgeData( _samples.length); // the expert judges the data, and may guess.
			}
		}
		
		//sets size of data chunks to be sent to DG. Called at beginning of new round
		public function setChunkSize():void{
			if(_level == 1){
				_chunkSize = 20;
			} else{
			var numChunks:int = _minNumChunks + (Math.random() * ((_maxNumChunks - _minNumChunks) + 1) as int);
			_chunkSize = ExpertAI.guessNumSamples / numChunks;
			trace("Chunk Size set to: " + _chunkSize);
			}
		}
		
		//sends a chunk of data to DG. called from 'sample' mxml button
		public function addChunk():void{
			for(var i:int = 0; i < _chunkSize; i++){
				addData();
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
		
		public function get sampleMedian():Number{	// median of samples generated by AddData()
			return _sampleMedian;
		}
		
		public function get populationMedian():Number{  // median of 'population' used by random number generator
			return _median;
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
		
		public function get level():int{
			return _level;
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
			if( this.lastBuzzer == UserPlayerSWC.instance ){
				return(_isWon ? "You were correct" : "You were incorrect"); 
			} else if( this.lastBuzzer == BotPlayerSWC.instance ){
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
			if( ExpertAI.DEBUG_alwaysWrong) {
				_guess = -100; // if the debug code has made the expert always wrong, guess this.
			} else {
				_guess = _sampleMedian; // Take the median of the data.
			}
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