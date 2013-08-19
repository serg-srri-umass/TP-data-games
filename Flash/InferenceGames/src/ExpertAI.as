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
			_guessPercent = calculateGuess();
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private static const BASE_GUESS:int = 85; // the guess will be around this number.
		private static const UNDER_RANGE:int = 6; // by how much the AI could guess under the base guess.
		private static const OVER_RANGE:int = 4; // by how much the AI could guess over the base guess. 
		
		private static var _guessPercent:int; // the % at which the expert will guess.
		
		// this is where the bot's thinking goes:
		public static function calculateGuess():int{
			var guessEarly:Boolean = Math.random() > 0.5; // if this is true, the guess will come earlier than the baseGuess.
			var deviation:Number; // how many % off of the baseGuess the bot will guess this round.
			
			deviation = guessEarly ? (-1 * Math.random() * UNDER_RANGE) : (Math.random() * OVER_RANGE); // deviate the guess, based on the over/under range.
			
			var guess:int = BASE_GUESS + deviation;
			trace("guess rate is: ", guess);
			return guess;
		}
		
	}
}