// this class holds information describing the current round.

package
{
	import common.MathUtilities;
	
	import embedded_asset_classes.ControlsSWC;
	import embedded_asset_classes.PlayerAPI;
	
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
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		private var _numDataSoFar:int = 0; // the number of dots that have been sent so far
		private static var _roundID:int = 0;		// ID number for this round
		
		private var _median:int; 
		private var _interval:Number;
		private var _IQR:Number; 		
		
		private var _guess:Number = 0;	// the auto-generated guess, based on the sample size.
										// currently, the user & the bot use the auto-generated guess.
										
		private var _accuracy:int; 		// the chances of guessing correctly at the current sample size.
		
		public var lastBuzzer:PlayerAPI; // the player who buzzed in this round.
		
		// constructor
		public function Round(param_interval:Number, param_IQR:Number){
			Round.currentRound = this;
			
			++_roundID;
			_interval = param_interval;
			_IQR = param_IQR;
			
			ControlsSWC.CONTROLS.interval = param_interval; // update the GUI.
			ControlsSWC.CONTROLS.IQR = param_IQR; // update the GUI.
			
			ExpertAI.newRound(); // prepare the AI for the new round.
		}
		
		// a point of data has been added.
		public function addData( value:Number = 0):void{
			
			value = Math.random() * 100; //TODO: generate data according to game parameters.
			
			_numDataSoFar++;
			ControlsSWC.CONTROLS.currentSampleMedian = calculateGuess(); // based on the data so far, calculate the best guess.
			_accuracy = calculateAccuracy();
			trace("count: ", numDataSoFar, " accuracy: ", _accuracy);
			
			InferenceGames.instance.sendEventData( [[ _roundID, value ]] );
			
			if(_accuracy > ExpertAI.guessPercent)		// when the accuracy goes above the expert's guessPercent, he guesses.
				InferenceGames.instance.hitBuzzer( IS_BOT);
		}
		
		public function get roundID():int{
			return _roundID;
		}		
		
		public function get numDataSoFar():int{
			return _numDataSoFar;
		}
		
		public function get interval():Number{
			return _interval;
		}
		
		public function get IQR():Number{
			return _IQR;
		}
		
		// get the automatically generated guess, based on the median of the sample data.
		public function get guess():Number{
			return _guess;
		}
		
		// get the accuracy of the current guess, based on the sample size:
		public function get accuracy():Number{
			return _accuracy;
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		// auto-generate a guess based on the median of the current sample.
		private function calculateGuess():Number{
			return 0; // Proxy. TO-DO: Take the mean of the data.
		}
		
		// generates an accuracy %, based on the sample size.
		private function calculateAccuracy():Number{
			return MathUtilities.calculateAreaUnderBellCurve( interval, numDataSoFar, MathUtilities.IQR_to_SD(IQR)) * 100;
		}
	}
}