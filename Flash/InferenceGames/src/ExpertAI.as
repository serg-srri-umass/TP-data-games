// This singleton class handles the AI of the "Statistician Expert"
package 
{	
	import common.MathUtilities;
	import embedded_asset_classes.InferenceEvent;
	import flash.events.*;
	import flash.utils.Timer;

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
			//if(Round.currentRound.level == 1){
				//_guessNumSamples = int.MAX_VALUE;
			//} else{
				_guessNumSamples = Math.round((Math.pow(((kExpertCallProbs[probIndex].z * standardDeviation)/interval), 2)));
			//}
			
			trace("confidence interval %: " + _confidenceIntervalPercent + ", expert will guess at N samples: " + _guessNumSamples);
			trace(standardDeviation, " ", interval);
		}

		// this method is called whenever data is added. The expert considers whether or not he wants to guess, and may guess.
		public static function judgeData( sampleLength:int):Boolean {
			var expertDidGuess:Boolean = ( sampleLength >= _guessNumSamples );
			return expertDidGuess;
		}
		
		// ------------ ANIMATION METHODS -------------------------
		
		private var sGameControls:SpaceRaceControls; // the game controls the expert is interacting with.
		private static const FULL_BOT_TYPE_DELAY:int = 1000; // how many miliseconds elapse before the bot starts typing its answer.

		private var thinkingTimer:Timer; // how many ms the expert has to think about whether to guess or not.
		private var _botEntryTimer:Timer = new Timer(FULL_BOT_TYPE_DELAY, 0); // used to simulate the opponent typing his answer.
		
		
		// constructor
		public function ExpertAI( controls:SpaceRaceControls):void{
			sGameControls = controls;
			sGameControls.addEventListener( InferenceEvent.EXPERT_START_TURN, startExpertTurn);		// the controls dispatch an event when they enter the expert's turn.
			sGameControls.addEventListener( InferenceEvent.EXPERT_START_TYPING, enterGuess);		// the controls dispatch an event when they enter the expert's turn.
			
			thinkingTimer = new Timer(100, 1);
			thinkingTimer.addEventListener(TimerEvent.TIMER, decideGuessPass);
			
			_botEntryTimer.addEventListener( TimerEvent.TIMER, handleBotType);
		}
		
		public function startExpertTurn( triggerEvent:InferenceEvent):void{
			trace("STARTING EXPERT TURN...");
			thinkingTimer.delay = getThinkingTime();
			trace(thinkingTimer.delay, "ms delay");
			thinkingTimer.reset();
			thinkingTimer.start();
		}
		
		// how long does the Expert have to think about this choice?
		// this logic should eventually be semi-complex. Ie, lower levels = more thinking time, because the player is new.
		// higher levels = less thinking time, because the player knows how it works.
		// also, if the % is close to guessing, the expert might take a longer time, to simulate mulling it over.
		private function getThinkingTime():int{
			return 1000;	// to do: make this dynamic.
		}
		
		// the expert decides whether or not to guess this turn
		private function decideGuessPass( triggerEvent:Event = null):void{
			trace("The expert is deciding whether to guess or pass...");
			trace("expert will guess @ " + _guessNumSamples);
			trace("current num samples: " + Round.currentRound.numDataSoFar);
			
			var willGuess:Boolean = judgeData( Round.currentRound.numDataSoFar);
			if( willGuess){
				doGuess();
			} else {
				doPass();
			}
		}
		
		// the expert has decided to pass:
		private function doPass( triggerEvent:Event = null):void{
			sGameControls.controlsGreenMVC.passMVC.play();
			var passTimer:Timer = new Timer(350, 1);	// how long it holds on 'pause', before the action actually happens
			passTimer.addEventListener( TimerEvent.TIMER, sGameControls.passGreen);
			passTimer.start();
		}
		
		private function doGuess( triggerEvent:Event = null):void{
			sGameControls.controlsGreenMVC.guessMVC.play();
			var openGuessTimer:Timer = new Timer(350, 1);	// how long it holds on 'pause', before the action actually happens
			openGuessTimer.addEventListener( TimerEvent.TIMER, sGameControls.closeGuessPassGreen);
			openGuessTimer.start();
		}
		
		private function enterGuess( triggerEvent:Event = null):void{
			trace("EXPERT WILL START TYPING...");
			_botEntryTimer.delay = FULL_BOT_TYPE_DELAY;
			_botEntryTimer.reset();
			_botEntryTimer.start();
		}
		
		
		private function handleBotType( e:TimerEvent):void{
			var sampleMedianString:String = String(Round.currentRound.sampleMedian.toFixed(1));
			
			if( _botEntryTimer.currentCount == sampleMedianString.length){	// wait a full delay before hitting the okay button.
				_botEntryTimer.delay = FULL_BOT_TYPE_DELAY;
				sGameControls.moveGuessToText(); 	// when the bot finishes typing, move his guess interval into place.
			}
			
			if( _botEntryTimer.currentCount > sampleMedianString.length){ // the last character has been added. Hit the okay button.
				_botEntryTimer.stop();
				sGameControls.controlsGreenMVC.inputMVC.okMVC.play();
				var enterGuessTimer:Timer = new Timer(350, 1);	// how long it holds on 'pause', before the action actually happens
				enterGuessTimer.addEventListener( TimerEvent.TIMER, enterBotType);
				enterGuessTimer.start();
			} else {
				var outChar:String = sampleMedianString.charAt( _botEntryTimer.currentCount - 1);
				sGameControls.controlsGreenMVC.inputMVC.inputTxt.text += outChar; // add another character to the string
				_botEntryTimer.delay = _botEntryTimer.delay / 2; // half the time it will take to enter the next character. Simulates the accelarating way we type.
			}
		}
		
		private function enterBotType( e:Event):void{
			sGameControls.makeGuess();
		}
	}
}