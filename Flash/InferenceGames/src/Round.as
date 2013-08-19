// this class holds all data on the current round.

package
{
	import common.MathUtilities;
	
	import embedded_asset_classes.*;
	
	public class Round
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		public static var currentRound:Round;
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		private var _numDataSoFar:int = 0;
		
		private var _interval:Number;
		private var _IQR:Number; 		
		
		private var _guess:Number = 0;	// the auto-generated guess, based on the sample size.
		private var _accuracy:int; 		// the chances of guessing correctly at the current sample size.
		
		public var lastBuzzer:PlayerAPI;
		
		public function Round(param_interval:Number, param_IQR:Number){
			Round.currentRound = this;
			
			_interval = param_interval;
			_IQR = param_IQR;
			
			ControlsSWC.CONTROLS.interval = param_interval; // update the GUI.
			ControlsSWC.CONTROLS.IQR = param_IQR; // update the GUI.
		}
		
		// a point of data has been added.
		public function addData( value:Number = 0):void{
			_numDataSoFar++;
			ControlsSWC.CONTROLS.currentSampleMedian = calculateGuess(); // based on the data so far, calculate the best guess.
			_accuracy = calculateAccuracy();
			trace("count: ", numDataSoFar, " accuracy: ", _accuracy);
			
			if(_accuracy > 85){
				InferenceGames.hitBuzzer(false); // PROXY. TO-DO: Real bot answering.
			}
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