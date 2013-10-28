// This singleton class handles the AI of the "Statistician Expert"
package 
{
	import embedded_asset_classes.ControlsSWC;
	
	public class ExpertAI
	{
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		// the minimum % at which the expert will guess. 
		public static function get confidenceIntervalPercent():int{
			return _confidenceIntervalPercent;
		}
		
		public static function get guessNumSamples():int{
			return _guessNumSamples;
		}
		
		// call this method at the start of each new round.
		public static function newRound( standardDeviation:Number, interval:Number):void{
			calculateGuessN( standardDeviation, interval);
			Round.currentRound.setChunkSize();
		}
		
		// debug. When true, the expert will always guess incorrectly.
		public static function set DEBUG_alwaysWrong( arg:Boolean):void{
			_alwaysWrong = arg;
		}
		
		public static function get DEBUG_alwaysWrong ():Boolean{
			return _alwaysWrong;
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private static const BASE_GUESS:int = 85; // the guess will be around this number.
		private static const UNDER_RANGE:int = 6; // by how much the AI could guess under the base guess.
		private static const OVER_RANGE:int = 4; // by how much the AI could guess over the base guess. 
		public static const kExpertCallProbs:Array = [
			// confidence level as a percent, probability of expert picking this confidence level, Z value for calculating sample size needed.
			{ confPerc: 83,	prob: 0.10,	z: 1.39	},
			{ confPerc: 84,	prob: 0.20,	z: 1.41	},
			{ confPerc: 85,	prob: 0.25,	z: 1.44	},
			{ confPerc: 86,	prob: 0.20,	z: 1.47	},
			{ confPerc: 87,	prob: 0.10,	z: 1.52	},
			{ confPerc: 88,	prob: 0.07,	z: 1.57	},
			{ confPerc: 89,	prob: 0.04,	z: 1.61	},
			{ confPerc: 90,	prob: 0.04,	z: 1.64	}
		];
		
		private static var _alwaysWrong:Boolean = false; // debug. When true, the expert will always guess incorrectly.
		
		private static var _confidenceIntervalPercent:int;	// the confidence interval percent at which the expert will guess.
		private static var _guessNumSamples:int;	// number of samples at which expert will guess 
		
		
		public static function calculateGuessN(standardDeviation:Number, interval:Number):void{
			
			var prob:Number = 0;
			var lastProb:Number;
			var probIndex:int = 0;
			var rand:Number = Math.random();
			
			//randomly generate a confidence percentage. returned as an index to the array kExpertCallProbs. 
			for(var i:int = 0; i < kExpertCallProbs.length; i++){
				lastProb = prob; 
				prob += kExpertCallProbs[i].prob; 
				
				if(rand >= lastProb && rand < prob){
					probIndex = i;
					break;
				}
			}
			_confidenceIntervalPercent = kExpertCallProbs[probIndex].confPerc;
			
			//calculating 'N' to guess at if you want to guess with confidence interval implied by 'z'. 
			//expert does not guess on level 1
			if(Round.currentRound.level == 1){
				_guessNumSamples = int.MAX_VALUE;
			} else{
				_guessNumSamples = Math.round((Math.pow(((kExpertCallProbs[probIndex].z * standardDeviation)/interval), 2)));
			}
			
			trace("confidence interval %: " + _confidenceIntervalPercent + ", expert will guess at N samples: " + _guessNumSamples);
		}

		// this method is called whenever data is added. The expert considers whether or not he wants to guess, and may guess.
		public static function judgeData( sampleLength:int):Boolean {
			var expertDidGuess:Boolean = ( sampleLength >= _guessNumSamples );
			if( expertDidGuess )
				ControlsSWC.instance.botStopFunction();
			return expertDidGuess;
		}
	}
}