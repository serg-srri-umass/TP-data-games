// This singleton class handles the AI of the "Statistician Expert"
package 
{	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import common.MathUtilities;
	
	import embedded_asset_classes.InferenceEvent;

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
		//public static function newRound( standardDeviation:Number, interval:Number):void{
		//	calculateGuessN( standardDeviation, interval);
		//	Round.currentRound.setChunkSize();
		//}
		
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
		
		private static const kExpertThinkDelay:int = 1000; // how many miliseconds elapse before the bot selects pass or guess
		private static const kExpertTypeDelay:int = 1000; // how many miliseconds elapse before the bot starts typing its answer.
		private static const kExpertTypeAcceleration:Number = 1.75; // each keystroke is this many times faster than last when entering guess

		private static var _alwaysWrong:Boolean = false; // debug. When true, the expert will always guess incorrectly.
		
		private static var _confidenceIntervalPercent:int;	// the confidence interval percent at which the expert will guess.
		private static var _guessNumSamples:int;	// number of samples at which expert will guess 

			
		// randomly generate a confidence percentage from the array of weighted probabilities for each. returned as an index to the array kExpertCallProbs. 
		private static function getWeightedRandomCallProbIndex():int{
			var probIndex:int = 0;
			var prob:Number = 0;
			var rand:Number = Math.random();
			
			for(var i:int = 0; i < kExpertCallProbs.length; i++){
				prob += kExpertCallProbs[i].prob;
				if( rand < prob){
					probIndex = i;
					break;
				}
			}
			return probIndex;
		}
			
		// compute number of sample cases need for expert to guess, based on kExpertCallProbs
		public static function calculateGuessN(standardDeviation:Number, interval:Number):void{		
			var probIndex:int = getWeightedRandomCallProbIndex();
			
			_confidenceIntervalPercent = kExpertCallProbs[probIndex].confPerc;
			_guessNumSamples = Math.round((Math.pow(((kExpertCallProbs[probIndex].z * standardDeviation)/interval), 2)));
			
			trace("expert confidence interval %: " + _confidenceIntervalPercent + ", expert will guess at N samples: " + _guessNumSamples +
					" for StDev="+ standardDeviation, " tolerance=", interval);
		}
		
		// ------------ GUESS INPUTTING METHODS -------------------------
		
		private var sGameControls:SpaceRaceControls; // the game controls the expert is interacting with.
		private var thinkingTimer:Timer; // how many ms the expert has to think about whether to guess or not.
		private var _botEntryTimer:Timer = new Timer(kExpertTypeDelay, 0); // used to simulate the opponent typing his answer.
		
		
		// constructor
		public function ExpertAI( controls:SpaceRaceControls):void{
			sGameControls = controls;
			sGameControls.addEventListener( InferenceEvent.EXPERT_START_TURN, startExpertTurn);		// the controls dispatch an event when they enter the expert's turn.
			sGameControls.addEventListener( InferenceEvent.EXPERT_START_TYPING, startExpertTypeGuess);		// the controls dispatch an event when they enter the expert's turn.
			
			thinkingTimer = new Timer(100, 1);
			thinkingTimer.addEventListener(TimerEvent.TIMER, decideGuessPass);
			
			_botEntryTimer.addEventListener( TimerEvent.TIMER, handleExpertType);
		}
		
		public function startExpertTurn( triggerEvent:InferenceEvent):void{
			thinkingTimer.delay = getThinkingTime();
			trace( "expert turn start, with "+thinkingTimer.delay, "ms delay");
			thinkingTimer.reset();
			thinkingTimer.start();
		}
		
		// Expert's pause time before chosing pass or guess, in milliseconds
		// This is dynamic to give new users more time to see how expert play works.
		private function getThinkingTime():int{
			return kExpertThinkDelay * Round.currentRound.learningSlowdownFactor;
		}
		
		// Time between expert's keystrokes, in milliseconds, when "typing" a guess.
		// This is dynamic to give new users more time to see how expert play works.
		private function getTypingTime():int{
			return kExpertTypeDelay * Round.currentRound.learningSlowdownFactor;
		}
		
		// the expert decides whether or not to guess this turn
		private function decideGuessPass( triggerEvent:Event = null):void{
			var willGuess:Boolean = ( Round.currentRound.numDataSoFar >= _guessNumSamples );
			if( willGuess){
				trace("expert turn, GUESSES with "+Round.currentRound.numDataSoFar+" samples, guess at >="+_guessNumSamples );
				doGuess();
			} else {
				trace("expert turn, PASSES with "+Round.currentRound.numDataSoFar+" samples, guess at >="+_guessNumSamples );
				doPass();
			}
		}
		
		// the expert has decided to pass:
		private function doPass( triggerEvent:Event = null):void{
			sGameControls.controlsExpertMVC.passMVC.play();
			var passTimer:Timer = new Timer(350, 1);	// how long it holds on 'pause', before the action actually happens
			passTimer.addEventListener( TimerEvent.TIMER, sGameControls.passExpert);
			passTimer.start();
		}
		
		private function doGuess( triggerEvent:Event = null):void{
			sGameControls.controlsExpertMVC.guessMVC.play();
			var openGuessTimer:Timer = new Timer(350, 1);	// how long it holds on 'pause', before the action actually happens
			openGuessTimer.addEventListener( TimerEvent.TIMER, sGameControls.closeGuessPassExpert);
			openGuessTimer.start();
		}
		
		// start the timer that "types" the expert guess
		private function startExpertTypeGuess( triggerEvent:Event = null):void{
			//trace("expert is starting to type, n="+Round.currentRound.numDataSoFar+", Pop. Mean="+Round.currentRound.populationMean);
			_botEntryTimer.delay = getTypingTime();
			_botEntryTimer.reset();
			_botEntryTimer.start();
		}
		
		// handle one frame of expert "typing" animation, including the finish of timer
		private function handleExpertType( e:TimerEvent):void{
			var sampleMeanString:String = String(Round.currentRound.sampleMean.toFixed(1));
			
			if( _botEntryTimer.currentCount <= sampleMeanString.length ) {
				// add another character to the "typed" string.
				var outChar:String = sampleMeanString.charAt( _botEntryTimer.currentCount - 1);
				sGameControls.controlsExpertMVC.inputMVC.inputTxt.text += outChar; // add another character to the string
				_botEntryTimer.delay = _botEntryTimer.delay / kExpertTypeAcceleration; // Simulates the accelarating way we type.
				if( _botEntryTimer.currentCount == sampleMeanString.length ) {
					// we've just added the last character
					_botEntryTimer.delay = getTypingTime();
					sGameControls.moveGuessToText(); 	// when the bot finishes typing, move his guess interval into place.
				}
			} else {
				// stop the timer and submit the guess
				trace( "expert typed: "+sampleMeanString );
				_botEntryTimer.stop();
				sGameControls.controlsExpertMVC.inputMVC.okMVC.play();
				var enterGuessTimer:Timer = new Timer(350, 1);	// how long it holds on 'pause', before the action actually happens
				enterGuessTimer.addEventListener( TimerEvent.TIMER, submitExpertGuess);
				enterGuessTimer.start();
			}
		}
		
		// called when the expert has finished typing to submit the guess and see if it is correct, show the distribution curve, etc.
		private function submitExpertGuess( e:Event):void{
			sGameControls.makeGuess();
		}
	}
}