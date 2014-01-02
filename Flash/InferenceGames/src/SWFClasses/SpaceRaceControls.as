package  {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flashx.textLayout.operations.MoveChildrenOperation;
	import flash.utils.Timer;
	import embedded_asset_classes.InferenceEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	public class SpaceRaceControls extends MovieClip {
		
		
		public static var INSTANCE:SpaceRaceControls;
		
		public var activePlayerIsRed:Boolean;
		private var updateTimer:Timer = new Timer(225, 1); // this timer is the delay between inputting text and the bar updating.
															// For example if a user types '44', the bar doesn't go to 4, then 44.
		private var isDraggingInterval:Boolean = false;
		
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
			
			draggingControlMVC.addEventListener( MouseEvent.MOUSE_OVER, highlightInterval);
			draggingControlMVC.addEventListener( MouseEvent.MOUSE_OUT, unhighlightInterval);
			barMVC.alpha = 0; // don't show the guessing bar.
			draggingControlMVC.addEventListener( MouseEvent.MOUSE_DOWN, startDragFunc);
			
			controlsGreenMVC.inputMVC.inputTxt.restrict="0-9.";	// only allow 0-9 and .
			controlsRedMVC.inputMVC.inputTxt.restrict="0-9.";
			controlsGreenMVC.inputMVC.inputTxt.addEventListener( KeyboardEvent.KEY_DOWN, listenForEnter);
			controlsRedMVC.inputMVC.inputTxt.addEventListener( KeyboardEvent.KEY_DOWN, listenForEnter);
			controlsGreenMVC.inputMVC.inputTxt.addEventListener( Event.CHANGE, updateGuessNumber);
			controlsRedMVC.inputMVC.inputTxt.addEventListener( Event.CHANGE, updateGuessNumber);
			
			updateTimer.addEventListener(TimerEvent.TIMER, moveGuessToText);
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
			var t:Tween = new Tween( barMVC, "alpha", None.easeNone, barMVC.alpha, 1, 12); 
			draggingControlMVC.mouseEnabled = true;
			draggingControlMVC.buttonMode = true;
			controlsRedMVC.gotoAndPlay("openInputCancel");
		}
		
		public function closeGuessPassRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeGuessPass");
			controlsRedMVC.queueFunction = dispatchRedGuessRequest;
		}
		
		public function cancelInputRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeInputCancel");
			hideFeedback();
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
			var t:Tween = new Tween( barMVC, "alpha", None.easeNone, barMVC.alpha, 1, 12); 
			draggingControlMVC.mouseEnabled = true;
			draggingControlMVC.buttonMode = true;
			controlsGreenMVC.gotoAndPlay("openInputCancel");
		}
		
		public function closeGuessPassGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.gotoAndPlay("closeGuessPass");
			controlsGreenMVC.queueFunction = dispatchGreenGuessRequest;
		}
		
		public function cancelInputGreen( triggerEvent:Event = null):void{
			controlsGreenMVC.gotoAndPlay("closeInputCancel");
			hideFeedback();
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
			myGuess = constrainMinMax( myGuess);
				
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
		
		public function hideFeedback( triggerEvent:Event = null):void{
			var t1:Tween = new Tween( barMVC, "alpha", None.easeNone, barMVC.alpha, 0, 12);
			draggingControlMVC.mouseEnabled = false;
			draggingControlMVC.buttonMode = false;
			feedbackMVC.visible = false;
		}
		
		// dispatch a request for the new round, and hide the 'new round button'
		private function dispatchRequestNewRound(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_NEW_ROUND, true));
			hideFeedback();
		}
		
		// dispatch a request for a green guess
		private function dispatchGreenGuessRequest(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_GUESS_MODE_GREEN, true));
		}
		
		// dispatch a request for a red guess
		private function dispatchRedGuessRequest(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_GUESS_MODE_RED, true));
		}
		
		// if the player hits enter, while typing in the textbox, make the guess
		private function listenForEnter( triggerEvent:KeyboardEvent):void{
			if( triggerEvent.charCode == 13){ // enter
				makeGuess();
			}			
		}
		
		
		private function updateGuessNumber( triggerEvent:Event = null):void{
			updateTimer.reset();
			updateTimer.start();
		}
		
		// this method moves the guess-interval to the text's position.
		private function moveGuessToText( triggerEvent:Event = null):void{
			// if the keypress isn't "ENTER", we want to move the guess rect. to the guess' location
			var guessLocation:Number = validateGuess();
			if( guessLocation >= 0 && guessLocation <= 100){	// the bar goes from 0 - 100
				var newX:Number = SpaceRaceBody.INSTANCE.numlineToStage( guessLocation);
				var t1:Tween = new Tween( barMVC, "x", Regular.easeOut, barMVC.x, newX, 12);
			} else {	// if the # is invalid, hide the bar.
				if(guessLocation < 0)
					var t2:Tween = new Tween( barMVC, "x", Regular.easeOut, barMVC.x, SpaceRaceBody.INSTANCE.numlineToStage(0), 12);
				if(guessLocation > 100)
					var t3:Tween = new Tween( barMVC, "x", Regular.easeOut, barMVC.x, SpaceRaceBody.INSTANCE.numlineToStage(100), 12);
			}
		}
		
		
		
		
		private function startDragFunc( triggerEvent:MouseEvent):void{
			if( !isDraggingInterval){
				barMVC.startDrag(true, new Rectangle( SpaceRaceBody.INSTANCE.startPoint, SpaceRaceBody.INSTANCE.numberlineY - (barMVC.width/2), SpaceRaceBody.INSTANCE.endPoint - SpaceRaceBody.INSTANCE.startPoint, 0));
				SpaceRaceBody.INSTANCE.myStage.addEventListener(MouseEvent.MOUSE_MOVE, updateGuess);
				SpaceRaceBody.INSTANCE.myStage.addEventListener( MouseEvent.MOUSE_UP, stopDragFunc);
				isDraggingInterval = true;
			}
		}
		
		private function stopDragFunc( triggerEvent:MouseEvent):void{
			if( isDraggingInterval){
				SpaceRaceBody.INSTANCE.myStage.removeEventListener(MouseEvent.MOUSE_MOVE, updateGuess);
				SpaceRaceBody.INSTANCE.myStage.removeEventListener( MouseEvent.MOUSE_UP, stopDragFunc);
				barMVC.stopDrag();
				isDraggingInterval = false;
			}
		}
		
		private function updateGuess( triggerEvent:MouseEvent = null):void{
			var activeControls:MovieClip = (activePlayerIsRed ? controlsRedMVC : controlsGreenMVC);
			activeControls.inputMVC.inputTxt.text = String(	constrainMinMax( SpaceRaceBody.INSTANCE.stageToNumline( barMVC.x)).toFixed(1));
		}
		
		// given a number, if < 100, return 100. If > 0, return 0. Otherwise, return number.
		public function constrainMinMax( arg:Number):Number{
			if( arg < 0)
				return 0;
			if( arg > 100)
				return 100;
			return arg;
		}
		
		
		//draggingControlMVC runs across the entire numberline. Mousing over it highlights the interval bar.
		private function highlightInterval( triggerEvent:Event):void{
			barMVC.gotoAndStop(2);
		}
		private function unhighlightInterval( triggerEvent:Event):void{
			barMVC.gotoAndStop(1);
		}
		
	}	
	
}
