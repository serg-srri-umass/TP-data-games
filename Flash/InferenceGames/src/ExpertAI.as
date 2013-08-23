// This singleton class handles the AI of the "Statistician Expert"
package 
{
	public class ExpertAI
	{
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		// the minimum % at which the expert will guess. 
		public static function get guessPercent():int{
			return _guessPercent;
		}
		
		// call this method at the start of each new round.
		public static function newRound():void{
			_guessPercent = calculateGuessPercent();
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
		
		private static var _guessPercent:int; // the % at which the expert will guess.
		//private static var _roundsSD:Number;
		//private static var _roundsInterval;
		
		// calculate the confidence level that the Expert (Bot) will guess at, returns a percent in range [0-100]
		// this is where the bot's thinking goes:
		public static function calculateGuessPercent():int{
			var guessEarly:Boolean = Math.random() > 0.5; // if this is true, the guess will come earlier than the baseGuess.
			var deviation:Number; // how many % off of the baseGuess the bot will guess this round.
			
			deviation = guessEarly ? (-1 * Math.random() * UNDER_RANGE) : (Math.random() * OVER_RANGE); // deviate the guess, based on the over/under range.
			
			var guess:int = BASE_GUESS + deviation;
			trace("guess rate is: ", guess);
			return guess;
		}
		
	}
}