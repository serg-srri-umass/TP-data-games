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
		public static var currentRound:Round; // the round object we're currently playing.
		
		public static const kLevelSettings:ArrayCollection = new ArrayCollection([
			{ sd:5,	    tolerance:1	}, // level 1: +/- 1 standard deviation = 5 units, tolerance of guess, +/- 1 unit.
			{ sd:5,		tolerance:"?"},
			{ sd:"?",	tolerance:1	},
			{ sd:"?",	tolerance:"?"} // level 4
		]);
		public static const kLevel2tolerances:Array = [3, 2, 1, 3, 4];
		public static const kLevel3stDev:Array = [5, 2, 1, 5, 7, 10];
		public static const kLevel4tolerances:Array = [4, 4, 3, 2,  1, 3];
		public static const kLevel4stDev:Array      = [1, 5, 7, 10, 5, 2];
		
		public static const kPossibleStDevs:Array = [10,7,5,2,1];
		public static const kStartingStDev:Number = 7; 
		public static const kPossibleTolerances:Array = [4,3,2,1];
		public static const kStartingTolerance:Number = 1;
		
		public static const luckyPercent:int = 49; // if you guess right at this percent or less, you got lucky
		public static const unluckyPercent:int = 70; // if you guess wrong at this percent or more, you got unlucky 
		
		public static const kChunkSizeProbs:ArrayCollection = new ArrayCollection([
			{ chunks:2, percent:3		}, // probability of chunk size 2 is 3%
			{ chunks:3, percent:23		},
			{ chunks:4, percent:33		},
			{ chunks:5, percent:18		},
			{ chunks:6, percent:12		},
			{ chunks:7, percent:5		},
			{ chunks:8, percent:3		},
			{ chunks:9, percent:2		},
			{ chunks:10, percent:1		}, // total of percents adds up to 100
		]);
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		private static var _roundID:int = 0;		// ID number for this round
		private static var _nextToleranceIndex:int = -1; // inc'd each round to set next tolerance on level 3. Neg so first inc brings to 0.
		private static var _nextStDevIndex:int = -1; 	// inc'd each round to set next StDev on leve 4. Neg so first inc brings to 0.
		
		private var _sample:Vector.<Number> = new Vector.<Number>(); // array of numeric values generated for this round
		private var _sampleMean:Number;		
		private var _popMean:Number; 	// population median
		private var _tolerance:Number;
		private var _StDev:Number; 		// population standard deviation	
		private var _chunkSize:int;
		private var _accuracy:int; 		// the chances of guessing correctly at the current sample size (range 0-100)
		private var _resultString:String = ""; // Result of round: "You won/lost", "Expert won/lost", etc, for DG results attribute
		private var _minOfRange:int = 0;	// lower end of guessing range for this round, 0 for means in 0-100, 100 for means in 100-200, etc.
		
		private var _isWon:Boolean = false; // whether or not this round has been won, calculated when we call for the results string
		private var _expertGuessed:Boolean = false;	// true if the expert has guessed during this round
		private var _level:int = 0; //level of this round
		
		private var dataTimer:Timer;
		private const _dataDelayTime:int = 50; //delay time between sending points to DG in ms
		
	
		// constructor
		public function Round( whichLevel:int ) {
			DebugUtilities.assert( whichLevel >= 1 && whichLevel <= kLevelSettings.length, "whichLevel out of range" );
			
			Round.currentRound = this;
			++_roundID;
			
			// setting IQR and Interval based on level
			switch(whichLevel){
				case 1:
					_tolerance 	= kLevelSettings[ whichLevel-1 ].tolerance;
					_StDev 		= kLevelSettings[ whichLevel-1 ].sd;
					InferenceGames.instance.sSpaceRace.bodyMVC.setPossibleTolerances(kLevelSettings[0].tolerance); //only show 1 tolerance
					InferenceGames.instance.sSpaceRace.bodyMVC.setPossibleSDs(kLevelSettings[0].sd); //only show 1 StDev
					InferenceGames.instance.sSpaceRace.setInterval(_tolerance);
					InferenceGames.instance.sSpaceRace.setIQR(_StDev);
					break;
				case 2:
					_nextToleranceIndex = (_nextToleranceIndex + 1) % kLevel2tolerances.length; // next index in bounds
					_StDev = kLevelSettings[ whichLevel-1 ].sd;
					_tolerance = kLevel2tolerances[_nextToleranceIndex];
					InferenceGames.instance.sSpaceRace.bodyMVC.setPossibleSDs(kLevelSettings[1].sd); //only show 1 StDev
					InferenceGames.instance.sSpaceRace.setInterval(_tolerance);
					InferenceGames.instance.sSpaceRace.setIQR(_StDev);
					break;
				case 3:
					_nextStDevIndex = (_nextStDevIndex + 1) % kLevel3stDev.length; // next index in bounds
					_tolerance = kLevelSettings[ whichLevel-1 ].tolerance;
					_StDev	  = kLevel3stDev[_nextStDevIndex];
					InferenceGames.instance.sSpaceRace.bodyMVC.setPossibleTolerances(kLevelSettings[2].tolerance); //only show 1 tolerance
					InferenceGames.instance.sSpaceRace.setInterval(_tolerance);
					InferenceGames.instance.sSpaceRace.setIQR(_StDev);
					break;
				case 4: 
					_nextToleranceIndex = (_nextToleranceIndex + 1) % kLevel4tolerances.length; // next index in bounds
					_nextStDevIndex = (_nextStDevIndex + 1) % kLevel4stDev.length; // next index in bounds
					_tolerance = kLevel4tolerances[_nextToleranceIndex];
					_StDev	  = kLevel4stDev[_nextStDevIndex];
					InferenceGames.instance.sSpaceRace.setInterval(_tolerance);
					InferenceGames.instance.sSpaceRace.setIQR(_StDev);
					break;
				default:
					break;
			}
			
			_popMean 	= (Math.round(InferenceGames.instance.randomizer.uniformNtoM( 0, 100 ) * 10)/10);
			_minOfRange = 100 * Math.floor( _popMean / 100 );
			_sampleMean = 0;
			_level = whichLevel; 
			
			trace("Population Mean for new round: "+_popMean+" range: "+_minOfRange+"-"+(_minOfRange+100));
			trace(Round.currentRound);
			
			ExpertAI.newRound( _StDev, _tolerance); // prepare the AI for the new round.
		}
		
		//sets size of data chunks to be sent to DG. Called at beginning of new round
		public function setChunkSize():void{
			
			// pick a number of chunks from our weighted probilities
			var randomPercent:Number = MathUtilities.randomNumberBetween( 0, 100 ),
				cumulativePercent:Number = 0,
				numChunks:int = 1;
			for( var i:int=0; i<kChunkSizeProbs.length; i++ ) {
				cumulativePercent += kChunkSizeProbs[i].percent;
				if( randomPercent <= cumulativePercent ) {
					numChunks = kChunkSizeProbs[i].chunks;
					break;
				}
			}
			// calc the chunk size
			_chunkSize = ExpertAI.guessNumSamples / numChunks;
			if(_chunkSize == 0)
				_chunkSize = 1;
			trace("Chunk Size set to: " + _chunkSize + " Number of chunks ~ " + numChunks);
		}
		
		// when the next round comes, start using the 1st StDev and Tolerance values, if this level
		//		has variable StDev/Tolerance in each round. See Round().
		public static function resetNextRoundParams():void {
			_nextToleranceIndex = -1;
			_nextStDevIndex = -1;
		}
		
		public function get numDataSoFar():int{
			return _sample.length;
		}
		
		public function addData( data:Vector.<Number>):void{
			_sample = _sample.concat( data);
			_accuracy = calculateAccuracy();
			_sampleMean = calculateSampleMean();	// TO-DO: Use sample median.
		}
		
		public function get roundID():int {
			return _roundID;
		}		
		
		public function set roundID( newID:int ):void {
			_roundID = newID;
		}		
		
		public function get sampleMean():Number{	// median of samples generated by AddData()
			return _sampleMean;
		}
		
		public function get populationMean():Number{  // median of 'population' used by random number generator
			return _popMean;
		}
		
		public function get tolerance():Number {
			return _tolerance;
		}
		
		public function get StDev():Number {
			return _StDev;
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
		
		// generates an accuracy %, based on the sample size (range 0-100)
		public function calculateAccuracy():Number {
			if(numDataSoFar == 0){
				return _tolerance * 2; // if no samples, calculate chance of randomly guessing proper median given tolerance 
			}else{
				return 100 * MathUtilities.calculateAreaUnderBellCurve( tolerance * 2, numDataSoFar, _StDev );
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

		// get the result string showing who won or lost for this round
		public function getResultString():String {
			return _resultString;
		}
		
		public function setResultString( s:String ):void {
			_resultString = s;
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
		//private function randomRange(max:Number, min:Number = 0):Number{
		//	return Math.random() * (max - min) + min;
		//}
	}
}
