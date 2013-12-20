package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flashx.textLayout.operations.MoveChildrenOperation;
	
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
			controlsRedMVC.queueFunction = SpaceRaceBody.INSTANCE.prepareGuessRed;
		}
		
		public function cancelInputRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeInputCancel");
			controlsRedMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnRed;
		}
		
		public function passRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeGuessPass");
			controlsRedMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnNeutral;
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
			controlsGreenMVC.queueFunction = SpaceRaceBody.INSTANCE.prepareGuessGreen;
		}
		
		public function cancelInputGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.gotoAndPlay("closeInputCancel");
			controlsGreenMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnGreen;
		}
		
		public function passGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.gotoAndPlay("closeGuessPass");
			controlsGreenMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnNeutral;
		}
		
		
		
		
		// checks if the currently entered guess is valid. If it is, it returns true. Otherwise, it returns false & promps the user
		public function validateGuess( triggerEvent:Event = null):Number{
			var activeControls:MovieClip = (activePlayerIsRed ? controlsRedMVC : controlsGreenMVC)
			var textNum:Number = Number( activeControls.inputMVC.inputTxt.text)
			if ( isNaN( textNum ) || activeControls.inputMVC.inputTxt.text.length == 0){
				//controlsGreenMVC.inputMVC.invalidNumberMVC.visible = true;
				//controlsGreenMVC.inputMVC.invalidNumberMVC.gotoAndPlay(1);
				activeControls.inputMVC.inputTxt.text = "";
				return -1;
			}
			return textNum;
		}
		
		public function makeGuess( triggerEvent:Event = null):void{
			var myGuess:Number = validateGuess();
			if(myGuess >= 0){
				SpaceRaceBody.INSTANCE.makeGuess(myGuess);
			}
		}
		
		
	}
	
}
