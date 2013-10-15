// This MovieClip is the main game control. 
// It has the "Stop" button, the current average of the data,
// and the two "Shields" that display this round's
// interval and standard deviation.

/* STRUCTURE:
- this [labels: "hide", "show"]
	|- stopControlsMVC [labels: "pressStop"]
	|	|- stopStartBtn	[labels: "ready", "user", "bot"]
	|	|	|- pauseBtn [looks: stop(0), start(1)]
	|	|
	|	|- botGuessMVC
	|	|	|- guessTxt
	|	|	|- okayMVC
	|	|
	|	|- userGuessMVC
	|		|- guessTxt (input)
	|		|- okayBtn
	|		|- invalidNumberMVC
	|
	|- shieldsMVC
		|- intervalMVC [labels: "singleDigit", "doubleDigit"]
		|	|- intervalTxt
		|
		|- deviationMVC
		|- deviationTxt
*/

package embedded_asset_classes
{
	import common.TextFormatter;
	
	import flash.events.*;
	import flash.utils.Timer;
	
	public class ControlsSWC extends controlsSWC implements ShowHideAPI
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static var SINGLETON_CONTROLS:ControlsSWC;
		
		public static function get instance():controlsSWC{
			return SINGLETON_CONTROLS;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		// constructor
		public function ControlsSWC(){
			super();
			if(!SINGLETON_CONTROLS)
				SINGLETON_CONTROLS = this;
			else
				throw new Error("ControlsSWC has already been created.");
			
			visible = false;
			addEventListener(AnimationEvent.COMPLETE_HIDE, onCompleteHide); // handler for when hide animation is complete.
			stopControlsMVC.stopStartBtn.pauseBtn.setClickFunctions(stopFunction, startFunction); // the stop/start button uses these methods on click.
			stop();
			
			stopControlsMVC.stop();
			stopControlsMVC.userGuessMVC.okayBtn.addEventListener( MouseEvent.CLICK, validateGuess);
			
			_botEntryTimer.addEventListener( TimerEvent.TIMER, handleBotType);
		}
		
		// starts the show animation, making this MovieClip visible.
		public function show( triggerEvent:* = null):void{
			visible = true;
			stopControlsMVC.stopStartBtn.pauseBtn.look = 1; // set the button to 'start'
			stopControlsMVC.stopStartBtn.gotoAndStop( "ready");
			stopControlsMVC.gotoAndStop( 1); // show the start button, not the guess entry.
			stopControlsMVC.botGuessMVC.visible = false;
			stopControlsMVC.userGuessMVC.visible = false;
			stopControlsMVC.userGuessMVC.invalidNumberMVC.visible = false;
			
			gotoAndPlay("show");
			_isShowing = true;
		}
		
		// starts the hide animation. When it finishes, this MovieClip becomes invisible.
		public function hide( triggerEvent:* = null):void{
			gotoAndPlay("hide");
			_isShowing = false;
		}
		
		// sets the text on the IQR shield.
		// note: this is just a display. Changing this does not change the calculations.
		public function set IQR( param_iqr:String):void{
			shieldsMVC.deviationMVC.deviationTxt.text = param_iqr;
			shieldsMVC.deviationMVC.deviationTxt.setTextFormat(TextFormatter.BOLD);
		}
		
		// sets the text on the interval shield.
		// note: this is just a display. Changing this does not change the calculations.
		public function set interval( param_interval:Number):void{
			shieldsMVC.intervalMVC.intervalTxt.text = param_interval.toFixed(0);
			shieldsMVC.intervalMVC.intervalTxt.setTextFormat(TextFormatter.BOLD);
			
			if(param_interval >= 10) // bump over the +- sign if the interval is 2 digits.
				shieldsMVC.intervalMVC.gotoAndStop("doubleDigit");
			else
				shieldsMVC.intervalMVC.gotoAndStop("singleDigit");
		}
		
		public function get isShowing():Boolean{
			return _isShowing;
		}
		
		// call this method when the bot hits the stop button.
		public function botStopFunction():void{
			DataCannonSWC.instance.stopCannon();
			UserPlayerSWC.instance.hide();
			
			if( _autoGuess){
				
				Round.currentRound.guess = Round.currentRound.sampleMedian;
				InferenceGames.instance.hitBuzzer( false);
				//stopControlsMVC.userGuessMVC.okayBtn.mouseEnabled = false;
				
			} else {
				
				stopControlsMVC.stopStartBtn.pauseBtn.enabled = false;
				stopControlsMVC.gotoAndPlay("pressStop");
				stopControlsMVC.stopStartBtn.gotoAndStop( "bot");
				stopControlsMVC.botGuessMVC.visible = true;	
				stopControlsMVC.botGuessMVC.guessTxt.text = "";
				stopControlsMVC.botGuessMVC.okayMVC.gotoAndStop(1);
				
				_botEntryTimer.delay = FULL_BOT_TYPE_DELAY;
				_botEntryTimer.reset();
				_botEntryTimer.start();
				//InferenceGames.instance.hitBuzzer();
			}
		}
		
		// set whether the game automatically guesses for you or not.
		public function set DEBUG_autoGuess( arg:Boolean):void{
			_autoGuess = arg;
		}
		
		public function get DEBUG_autoGuess():Boolean{
			return _autoGuess;
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		private static const FULL_BOT_TYPE_DELAY:int = 1000; // how many miliseconds elapse before the bot starts typing its answer.
		private var _botEntryTimer:Timer = new Timer(FULL_BOT_TYPE_DELAY, 0); // used to simulate the opponent typing his answer.
		private var _autoGuess:Boolean; // whether the game automatically guesses for you or not. Can be turned on with the debug panel.
		
		private var _isShowing:Boolean = false;
		
		// this method is called when the player hits the stop button. Bring up the guess prompt.
		private function stopFunction( triggerEvent:MouseEvent):void{
			DataCannonSWC.instance.stopCannon();
			BotPlayerSWC.instance.hide();
			if( _autoGuess){
				
				Round.currentRound.guess = Round.currentRound.sampleMedian;
				InferenceGames.instance.hitBuzzer();
				stopControlsMVC.userGuessMVC.okayBtn.mouseEnabled = false;
				
			} else {
				stopControlsMVC.stopStartBtn.pauseBtn.enabled = false;
				stopControlsMVC.gotoAndPlay("pressStop");
				stopControlsMVC.stopStartBtn.gotoAndStop( "user");
				stopControlsMVC.userGuessMVC.visible = true;
				stopControlsMVC.userGuessMVC.okayBtn.mouseEnabled = true;
			
				// auto set the focus to the new text field:
				// taken from http://reality-sucks.blogspot.com/2007/11/actionscript-3-adventures-setting-focus.html
				InferenceGames.stage.focus = stopControlsMVC.userGuessMVC.guessTxt; 
				stopControlsMVC.userGuessMVC.guessTxt.text=" "; 
				stopControlsMVC.userGuessMVC.guessTxt.setSelection( stopControlsMVC.userGuessMVC.guessTxt.length, stopControlsMVC.userGuessMVC.guessTxt.length);
				stopControlsMVC.userGuessMVC.guessTxt.text = "";
				stopControlsMVC.userGuessMVC.guessTxt.addEventListener( KeyboardEvent.KEY_DOWN, checkForEnter); // check if the enter key has been pressed.
			}
		}
		
		// called when the player hits the start button.
		private function startFunction( triggerEvent:MouseEvent):void{
			stopControlsMVC.stopStartBtn.pauseBtn.look = 0;
			DataCannonSWC.instance.startCannon();			
		}
		
		// when the ControlsSWC finishes hiding itself, this method is called. It turns on the results.
		private function onCompleteHide( triggerEvent:AnimationEvent):void{
			visible = false;
			if(InferenceGames.instance.isInGame){
				ResultsSWC.instance.show();
			}
			else{
				LevelSelectSWC.instance.show();
			}
		}
		
		// checks if the currently entered guess is valid. If it is, it submits it. If not, it prompts the user.
		private function validateGuess( triggerEvent:MouseEvent = null):void{
			var textNum:Number = Number( stopControlsMVC.userGuessMVC.guessTxt.text)
			if ( isNaN( textNum ) || stopControlsMVC.userGuessMVC.guessTxt.text.length == 0){
				stopControlsMVC.userGuessMVC.invalidNumberMVC.visible = true;
				stopControlsMVC.userGuessMVC.invalidNumberMVC.gotoAndPlay(1);
				stopControlsMVC.userGuessMVC.guessTxt.text = "";
			}else{
				Round.currentRound.guess = textNum;
				InferenceGames.instance.hitBuzzer();
				stopControlsMVC.userGuessMVC.okayBtn.mouseEnabled = false;
				stopControlsMVC.userGuessMVC.guessTxt.removeEventListener( KeyboardEvent.KEY_DOWN, checkForEnter); // check if the enter key has been pressed.
			}
		}
		
		// this method handles the animation of the bot typing in his answer.
		private function handleBotType( triggerEvent:TimerEvent):void{
			var sampleMedianString:String = String(Round.currentRound.sampleMedian.toFixed(1));
			
			if( _botEntryTimer.currentCount == sampleMedianString.length)	// wait a full delay before hitting the okay button.
				_botEntryTimer.delay = FULL_BOT_TYPE_DELAY;
			
			if( _botEntryTimer.currentCount > sampleMedianString.length){ // the last character has been added. Hit the okay button.
				_botEntryTimer.stop();
				stopControlsMVC.botGuessMVC.okayMVC.gotoAndStop(2);
				Round.currentRound.calculateGuess();
				InferenceGames.instance.hitBuzzer( false); // false means the bot guessed.
			} else {
				var outChar:String = sampleMedianString.charAt( _botEntryTimer.currentCount - 1);
				stopControlsMVC.botGuessMVC.guessTxt.text += outChar; // add another character to the string
				_botEntryTimer.delay = _botEntryTimer.delay / 2; // half the time it will take to enter the next character. Simulates the accelarating way we type.
			}
		}
		
		// when typing in your guess, check for the enter key. If it's pressed, submit the guess.
		private function checkForEnter( triggerEvent:KeyboardEvent):void{
			if( triggerEvent.keyCode == 13) // 13 = enter key
				validateGuess();
		}
	}
}