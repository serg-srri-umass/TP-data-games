// this class holds information describing the current round.

package
{
	import common.DebugUtilities;
	import common.MathUtilities;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	
	public class Round
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		public static const WINNING_SCORE:int = 6; 	// how many points a player needs to win the game.
		public static var currentRound:Round; // the round object we're currently playing.
		
		public static const kLevelSettings:ArrayCollection = new ArrayCollection([
			{ iqr:7,	/*sd:5.2,*/	    interval:1	}, // level 1
			{ iqr:7,	/*sd:5.2,*/		interval:"?"},
			{ iqr:"?",	/*sd:10,*/		interval:1	},
			{ iqr:"?",	/*sd:20,*/		interval:"?"} // level 4
		]);
		
		public static const kIntervalWidth:Array = [3, 2, 1, 3, 4, 4]; // variable interval widths for levels with ?
		
		public static const kIQR:Array = [7, 3, 1, 7, 9, 12]; // variable IQRs for levels with ?
		
		public static const luckyPercent:int = 30; // if you guess right at this percent or less, you got lucky
		public static const unluckyPercent:int = 70; // if you guess wrong at this percent or more, you got unlucky 
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		private static var _roundID:int = 0;		// ID number for this round
		private static var _intervalIndex:int = -1; // inc'd each round to set next interval on level 3. Neg so first inc brings to 0.
		private static var _IQRIndex:int = -1; // inc'd each round to set next IQR on leve 4. Neg so first inc brings to 0.
		
		private var _sample:Vector.<Number> = new Vector.<Number>(); // array of numeric values generated for this round
		private var _sampleMedian:Number;		
		private var _median:Number; 		// population median
		private var _interval:Number;
		private var _IQR:Number; 		// population inter-quartile range	
		private var _chunkSize:int;
		private var _minNumChunks:int = 3;
		private var _maxNumChunks:int = 12;
		
		private var _accuracy:int; 		// the chances of guessing correctly at the current sample size.
		
		private var _isWon:Boolean = false; //whether or not this round has been won, calculated when we call for the results string
		private var _level:int = 0; //level of this round
		
		private var dataTimer:Timer;
		private const _dataDelayTime:int = 50; //delay time between sending points to DG in ms
		
		private var _expertGuessed:Boolean = false; 
	
		// constructor
		public function Round( whichLevel:int ) {
			DebugUtilities.assert( whichLevel >= 1 && whichLevel <= kLevelSettings.length, "whichLevel out of range" );
			
			Round.currentRound = this;
			++_roundID;
			
			// setting IQR and Interval based on level
			switch(whichLevel){
				case 1:
					_interval 	= kLevelSettings[ whichLevel-1 ].interval;
					_IQR 		= kLevelSettings[ whichLevel-1 ].iqr;
					InferenceGames.instance.sSpaceRace.bodyMVC.setPossibleIntervals(kLevelSettings[0].interval); //only show 1 interval
					InferenceGames.instance.sSpaceRace.bodyMVC.setPossibleIQRs(kLevelSettings[0].iqr); //only show 1 IQR
					InferenceGames.instance.sSpaceRace.setInterval(_interval);
					InferenceGames.instance.sSpaceRace.setIQR(_IQR);
					break;
				case 2:
					_intervalIndex = (_intervalIndex + 1) % kIntervalWidth.length; // next index in bounds
					_IQR = kLevelSettings[ whichLevel-1 ].iqr;
					_interval = kIntervalWidth[_intervalIndex];
					InferenceGames.instance.sSpaceRace.bodyMVC.setPossibleIQRs(kLevelSettings[1].iqr); //only show 1 IQR
					InferenceGames.instance.sSpaceRace.setInterval(_interval);
					InferenceGames.instance.sSpaceRace.setIQR(_IQR);
					break;
				case 3:
					_IQRIndex = (_IQRIndex + 1) % kIQR.length; // next index in bounds
					_interval = kLevelSettings[ whichLevel-1 ].interval;
					_IQR	  = kIQR[_IQRIndex];
					InferenceGames.instance.sSpaceRace.bodyMVC.setPossibleIntervals(kLevelSettings[2].interval); //only show 1 interval
					InferenceGames.instance.sSpaceRace.setInterval(_interval);
					InferenceGames.instance.sSpaceRace.setIQR(_IQR);
					break;
				case 4: 
					_intervalIndex = (_intervalIndex + 1) % kIntervalWidth.length; // next index in bounds
					_IQRIndex = (_IQRIndex + 1) % kIQR.length; // next index in bounds
					_interval = kIntervalWidth[_intervalIndex];
					_IQR	  = kIQR[_IQRIndex];
					InferenceGames.instance.sSpaceRace.setInterval(_interval);
					InferenceGames.instance.sSpaceRace.setIQR(_IQR);
					break;
				default:
					break;
			}
			
			_median 	= (Math.round(InferenceGames.instance.randomizer.uniformNtoM( 0, 100 ) * 10)/10);
			_sampleMedian = 0;
			_level = whichLevel; 
			
			trace("Population Median for new round: ", _median);
			
			trace(Round.currentRound);
			
			ExpertAI.newRound( MathUtilities.IQR_to_SD(_IQR), _interval); // prepare the AI for the new round.
		}
		
		//sets size of data chunks to be sent to DG. Called at beginning of new round
		public function setChunkSize():void{
			//if(_level == 1){
			//	_chunkSize = 20;
			//} else {
				var numChunks:int = randomRange(_maxNumChunks, _minNumChunks);
				_chunkSize = ExpertAI.guessNumSamples / numChunks;
				if(_chunkSize == 0)
					_chunkSize = 1;
				trace("Chunk Size set to: " + _chunkSize);
			//}
		}
		
		public function get numDataSoFar():int{
			return _sample.length;
		}
		
		public function addData( data:Vector.<Number>):void{
			_sample = _sample.concat( data);
			_accuracy = calculateAccuracy();
			_sampleMedian = calculateSampleMean();	// TO-DO: Use sample median.
		}
		
		public function get roundID():int {
			return _roundID;
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
		
		public function get chunkSize():int{
			return _chunkSize;
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
		
		// generates an accuracy %, based on the sample size.
		public function calculateAccuracy():Number {
			if(numDataSoFar == 0){
				return _interval * 2; // if no samples, calculate chance of randomly guessing proper median given interval 
			}else{
				return MathUtilities.calculateAreaUnderBellCurve( interval * 2, numDataSoFar, MathUtilities.IQR_to_SD(IQR)) * 100;
			}
		}
		
		public function calculateSampleMean():Number{
			var total:Number = 0;
			for( var i:int = 0; i < _sample.length; i++){
				total += _sample[i];
			}
			var mean:Number = total /= _sample.length;
			return mean;
		}

		// To-Do: Make this work, and/or move it into another class. (MS)
		// get the result string showing who won or lost for this round
		public function getResultsString():String {
			//calculateWinLose();
			return("the lastBuzzer variable is not set to the player, or the bot");
		}
		
		// returns true if the current guess was lucky.
		public function wasLucky():Boolean{
			return _accuracy < luckyPercent;
		}
		
		// returns true if the current guess was unlucky.
		public function wasUnlucky():Boolean{
			return _accuracy > unluckyPercent;
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		//returns random number within range passed to function
		private function randomRange(max:Number, min:Number = 0):Number{
			return Math.random() * (max - min) + min;
		}
	}
}
