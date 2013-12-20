package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flashx.textLayout.operations.MoveChildrenOperation;
	import flash.utils.Timer;
	import embedded_asset_classes.InferenceEvent;
	
	public class SpaceRaceControls extends MovieClip {
		
		
		public static var INSTANCE:SpaceRaceControls;
		
		public var activePlayerIsRed:Boolean;
		
		public function establish() {
			INSTANCE = this;

			// constructor code
			controlsRedMVC.guessBtn.addEventListener( MouseEvent.CLICK, closeGuessPassRed);
			controlsRedMVC.cancelBtn.addEventListener( MouseEvent.CLICK, cancelInputRed);
			controlsRedMVC.passBtn.addEventListener( MouseEvent.CLICK, passRed);
			controlsRedMVC.inputMVC.okBtn.addEventListener( MouseEvent.CLICK, makeGuess);
			
			controlsGreenMVC.guessBtn.addEventListener( MouseEvent.CLICK, closeGuessPassGreen);
			controlsGreenMVC.cancelBtn.addEventListener( MouseEvent.CLICK, cancelInputGreen);
			controlsGreenMVC.passBtn.addEventListener( MouseEvent.CLICK, passGreen);
			controlsGreenMVC.inputMVC.okBtn.addEventListener( MouseEvent.CLICK, makeGuess);
			
			feedbackMVC.newRoundBtnGreen.addEventListener( MouseEvent.CLICK, dispatchRequestNewRound);
			feedbackMVC.newRoundBtnRed.addEventListener( MouseEvent.CLICK, dispatchRequestNewRound);
			feedbackMVC.visible = false;
		}		
				
		public function hideRed( triggerEvent:Event = null):void{
			controlsRedMVC.visible = false;
		}
		
		public function showRed( triggerEvent:Event = null):void{
			controlsRedMVC.visible = true;
		}
		
		public function openGuessPassRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("openGuessPass");
		}
		
		public function openInputCancelRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("openInputCancel");
		}
		
		public function closeGuessPassRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeGuessPass");
			controlsRedMVC.queueFunction = dispatchRedGuessRequest;
		}
		
		public function cancelInputRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeInputCancel");
			controlsRedMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnRed;
		}
		
		public function passRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeGuessPass");
			controlsRedMVC.queueFunction = SpaceRaceBody.INSTANCE.startDataSampling;
		}
		
		
		
		public function hideGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.visible = false;
		}
		
		public function showGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.visible = true;
		}
		
		public function openGuessPassGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.gotoAndPlay("openGuessPass");
		}
		
		public function openInputCancelGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.gotoAndPlay("openInputCancel");
		}
		
		public function closeGuessPassGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.gotoAndPlay("closeGuessPass");
			controlsGreenMVC.queueFunction = dispatchGreenGuessRequest;
		}
		
		public function cancelInputGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.gotoAndPlay("closeInputCancel");
			controlsGreenMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnGreen;
		}
		
		public function passGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.gotoAndPlay("closeGuessPass");
			controlsGreenMVC.queueFunction = SpaceRaceBody.INSTANCE.startDataSampling;
		}
		
		// checks if the currently entered guess is valid. If it is, it returns true. Otherwise, it returns false & promps the user
		public function validateGuess( triggerEvent:Event = null):Number{
			var activeControls:MovieClip = (activePlayerIsRed ? controlsRedMVC : controlsGreenMVC);
			var textNum:Number = Number( activeControls.inputMVC.inputTxt.text)
			if ( isNaN( textNum ) || activeControls.inputMVC.inputTxt.text.length == 0){
				activeControls.inputMVC.inputTxt.text = "";
				return Number.NaN;
			}
			return textNum;
		}
		
		public function makeGuess( triggerEvent:Event = null):void{
			var myGuess:Number = validateGuess();
			if( isNaN(myGuess))
				return; // don't allow invalid guesses.
				
			SpaceRaceBody.INSTANCE.guess = myGuess; // set the guess value
			SpaceRaceBody.INSTANCE.promptTxt.text = "";
			var activeControls:MovieClip = (activePlayerIsRed ? controlsRedMVC : controlsGreenMVC);
			activeControls.gotoAndPlay("closeInputCancel");
			activeControls.queueFunction = delayedMakeGuess;
		}
		
		// a delay occurs between when the guess prompt hides itself, and the answer is revealed.
		public function delayedMakeGuess( triggerEvent:Event = null):void{
			var delayTimer:Timer = new Timer( 600, 1); // delay time
			delayTimer.addEventListener(TimerEvent.TIMER, SpaceRaceBody.INSTANCE.makeGuess);
			delayTimer.start();
		}
		
		// this method shows the feedback & next round button that appear after playing a round
		public function showFeedback(header:String, body:String = ""):void{
			hideGreen();
			hideRed();
			feedbackMVC.visible = true;
			feedbackMVC.headerTxt.text = header;
			feedbackMVC.bodyTxt.text = body;
			
			if(activePlayerIsRed){
				feedbackMVC.newRoundBtnGreen.visible = false;
				feedbackMVC.newRoundBtnRed.visible = true;
			} else {
				feedbackMVC.newRoundBtnGreen.visible = true;
				feedbackMVC.newRoundBtnRed.visible = false;
			}
		}
		
		// dispatch a request for the new round, and hide the 'new round button'
		private function dispatchRequestNewRound(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_NEW_ROUND, true));
			feedbackMVC.visible = false;
		}
		
		// dispatch a request for a green guess
		private function dispatchGreenGuessRequest(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_GUESS_MODE_GREEN, true));
		}
		
		// dispatch a request for a red guess
		private function dispatchRedGuessRequest(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_GUESS_MODE_RED, true));
		}
	}
	
}
