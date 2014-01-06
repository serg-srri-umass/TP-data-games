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
	import flash.text.TextFormat;
	
	public class SpaceRaceControls extends MovieClip {
		//
		// The SpaceRaceControls are the parts of SpaceRaceBody that players interact with.
		// It includes the buttons, draggable interval, cancel button, etc.
		// (It does NOT include the top bar.)
		//
		
		public static var INSTANCE:SpaceRaceControls;
		
		private var t1:Tween, t2:Tween, t3:Tween, t4:Tween, t5:Tween, t6:Tween, t7:Tween, t8:Tween, t9:Tween, t10:Tween; 
		//Tweens should never be declaired in a method's scope, because they might be garbage collected before they complete.
		
		public var activePlayerIsRed:Boolean;	// is the active player the red player?
		private var updateTimer:Timer = new Timer(300, 1); // this timer is the delay between inputting text and the bar updating.
															// For example if a user types '44', the bar doesn't go to 4, then 44.
		private var isDraggingInterval:Boolean = false;	// whether or not the player is dragging the guess - interval.
		
		// this method acts like a fake constructor. It has to be called before anything can be done with the SpaceRaceControls.
		public function establish() {
			INSTANCE = this;

			controlsRedMVC.guessBtn.addEventListener( MouseEvent.CLICK, closeGuessPassRed);
			controlsRedMVC.cancelBtn.addEventListener( MouseEvent.CLICK, cancelInputRed);
			controlsRedMVC.passBtn.addEventListener( MouseEvent.CLICK, passRed);
			controlsRedMVC.inputMVC.okBtn.addEventListener( MouseEvent.CLICK, makeGuess);
			feedbackMVC.newRoundBtnRed.addEventListener( MouseEvent.CLICK, dispatchRequestNewRound);
			feedbackMVC.visible = false;
			
			draggingControlMVC.addEventListener( MouseEvent.MOUSE_OVER, highlightInterval);
			draggingControlMVC.addEventListener( MouseEvent.MOUSE_OUT, unhighlightInterval);
			draggingControlMVC.addEventListener( MouseEvent.MOUSE_DOWN, startDragFunc);
			barMVC.alpha = 0; // don't show the guessing bar.
			
			controlsRedMVC.inputMVC.inputTxt.addEventListener( KeyboardEvent.KEY_DOWN, listenForEnter);
			controlsRedMVC.inputMVC.inputTxt.addEventListener( Event.CHANGE, updateGuessNumber);
			controlsRedMVC.inputMVC.inputTxt.restrict="0-9."; // only allow numerals in the guessing box
			
			updateTimer.addEventListener(TimerEvent.TIMER, moveGuessToText);
			disableEndGameBtn();
			
			mainMenuMVC.newGameBtn.addEventListener( MouseEvent.CLICK, dispatchRequestNewGame);
			mainMenuMVC.changeLevelBtn.addEventListener( MouseEvent.CLICK, dispatchRequestChangeLevels);
			mainMenuMVC.visible = false;
		}		
		
		// --- RED SECTION ------------------------------------------------------------------------
		// makes red controls invisible
		public function hideRed( triggerEvent:Event = null):void{
			controlsRedMVC.visible = false;
		}
		
		// makes red controls visible.
		public function showRed( triggerEvent:Event = null):void{
			controlsRedMVC.visible = true;
		}
		
		// opens the "primary controls". The red player has two buttons "Guess" and "Pass"
		public function openGuessPassRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("openGuessPass");
			enableEndGameBtn();
		}
		
		// opens the "guessing controls". The red player has two options: Input a guess, or cancel.
		// this also makes the guess-interval visible.
		public function openInputCancelRed( triggerEvent:Event = null):void{
			t1 = new Tween( barMVC, "alpha", None.easeNone, barMVC.alpha, 1, 12); 
			draggingControlMVC.mouseEnabled = true;
			draggingControlMVC.buttonMode = true;
			barMVC.y = SpaceRaceBody.INSTANCE.numberlineY; // - (barMVC.width/2);
			controlsRedMVC.gotoAndPlay("openInputCancel");
		}
		
		// this method closes the "guessing controls" and causes it to dispatch a guess request.
		public function closeGuessPassRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeGuessPass");
			controlsRedMVC.queueFunction = dispatchRedGuessRequest;
		}
		
		// cancel the "guessing controls" and return to the "primary controls".
		public function cancelInputRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeInputCancel");
			hideFeedback();
			controlsRedMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnRed;
		}
		
		// red player passes. Next, the green player's turn starts.
		public function passRed( triggerEvent:Event = null):void{
			controlsRedMVC.gotoAndPlay("closeGuessPass");
			controlsRedMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnGreen;
			disableEndGameBtn();
		}
		
		
		// --- GREEN SECTION ------------------------------------------------------------------------
		// To-Do: Should the green player's controls no longer mirror the red player?
		
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
			t2 = new Tween( barMVC, "alpha", None.easeNone, barMVC.alpha, 1, 12); 
			draggingControlMVC.mouseEnabled = false;
			draggingControlMVC.buttonMode = false;
			barMVC.y = SpaceRaceBody.INSTANCE.numberlineY;// - (barMVC.width/2);
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
		
		// ---------------------------------------------------------
		// --- GUESSING SECTION ------------------------------------
		
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
		
		// this method submits a guess. First, it validates the guess. If the guess is invalid (NaN, or out of range), nothing happens.
		// otherwise, the guess is submitted.
		public function makeGuess( triggerEvent:Event = null):void{
			var myGuess:Number = validateGuess();
			if( isNaN(myGuess))
				return; // don't allow invalid guesses.
			myGuess = constrainMinMax( myGuess);
			
			draggingControlMVC.mouseEnabled = false;	// once the guess has been placed, don't let them drag the interval any more
			draggingControlMVC.buttonMode = false;
				
			SpaceRaceBody.INSTANCE.guess = myGuess; // set the guess value.
			SpaceRaceBody.INSTANCE.promptTxt.text = ""; // clear the text field.
			
			var activeControls:MovieClip = (activePlayerIsRed ? controlsRedMVC : controlsGreenMVC);
			activeControls.gotoAndPlay("closeInputCancel");
			activeControls.queueFunction = delayedMakeGuess;			
			disableEndGameBtn();
		}
		
		// a delay occurs between when the guess prompt hides itself, and the answer is revealed.
		public function delayedMakeGuess( triggerEvent:Event = null):void{
			var delayTimer:Timer = new Timer( 600, 1); // delay time
			delayTimer.addEventListener(TimerEvent.TIMER, SpaceRaceBody.INSTANCE.makeGuess);
			delayTimer.start();
		}
		
		// this method shows the feedback & next round button that appear after playing a round
		public function showFeedback(header:String, buttonText:String, body:String = ""):void{
			hideGreen();
			hideRed();
			feedbackMVC.visible = true;
			t10 = new Tween(feedbackMVC, "alpha", None.easeNone, 0, 1, 10); // fade-in in 10 frames
			
			feedbackMVC.headerTxt.text = header;
			feedbackMVC.bodyTxt.text = body;
			
			var tf:TextFormat = new TextFormat();	// text format makes it bold
			tf.bold = true;
			feedbackMVC.newRoundBtnRed.buttonTxt.defaultTextFormat = tf;
			feedbackMVC.newRoundBtnRed.buttonTxt.text = buttonText;
		}
		
		// this method hides the feedback.
		public function hideFeedback( triggerEvent:Event = null):void{
			t3 = new Tween( barMVC, "alpha", None.easeNone, barMVC.alpha, 0, 12); // fade-out in 10 frames
			draggingControlMVC.mouseEnabled = false;
			draggingControlMVC.buttonMode = false;
			feedbackMVC.visible = false;
		}
		
		// if the player hits enter, while typing in the textbox, make the guess
		private function listenForEnter( triggerEvent:KeyboardEvent):void{
			if( triggerEvent.charCode == 13){ // enter
				makeGuess();
			}			
		}
		
		// this method moves the guess-interval to the text's position.
		public function moveGuessToText( triggerEvent:Event = null):void{
			// if the keypress isn't "ENTER", we want to move the guess rect. to the guess' location
			var guessLocation:Number = validateGuess();
			if( guessLocation >= 0 && guessLocation <= 100){	// the bar goes from 0 - 100
				var newX:Number = SpaceRaceBody.INSTANCE.numlineToStage( guessLocation);
				t4 = new Tween( barMVC, "x", Regular.easeOut, barMVC.x, newX, 12); // move the X value of the interval bar over 12 frames
			} else {	// if the # is outside of the possible range, move it to the extreme value.
				if(guessLocation < 0)
					t5 = new Tween( barMVC, "x", Regular.easeOut, barMVC.x, SpaceRaceBody.INSTANCE.numlineToStage(0), 12); // move X value of interval bar
				if(guessLocation > 100)
					t6 = new Tween( barMVC, "x", Regular.easeOut, barMVC.x, SpaceRaceBody.INSTANCE.numlineToStage(100), 12); // move X value of interval bar
			}
		}
		
		// start dragging the interval rectangle.
		private function startDragFunc( triggerEvent:MouseEvent):void{
			if( !isDraggingInterval){
				barMVC.startDrag(true, new Rectangle( SpaceRaceBody.INSTANCE.startPoint, SpaceRaceBody.INSTANCE.numberlineY - (barMVC.width/2), (SpaceRaceBody.INSTANCE.endPoint - SpaceRaceBody.INSTANCE.startPoint) + 1, 0));
				SpaceRaceBody.INSTANCE.myStage.addEventListener(MouseEvent.MOUSE_MOVE, updateGuess);
				SpaceRaceBody.INSTANCE.myStage.addEventListener( MouseEvent.MOUSE_UP, stopDragFunc);
				isDraggingInterval = true;
			}
		}
		
		// stop dragging the interval rectangle.
		private function stopDragFunc( triggerEvent:MouseEvent):void{
			if( isDraggingInterval){
				SpaceRaceBody.INSTANCE.myStage.removeEventListener(MouseEvent.MOUSE_MOVE, updateGuess);
				SpaceRaceBody.INSTANCE.myStage.removeEventListener( MouseEvent.MOUSE_UP, stopDragFunc);
				barMVC.stopDrag();
				updateGuess( triggerEvent);	// allow the player to 'snap' the guess to a specific point with a single click.
				isDraggingInterval = false;
			}
		}
		
		// this method updates the guess text to reflect the position of the draggy-interval.
		private function updateGuess( triggerEvent:MouseEvent = null):void{
			var activeControls:MovieClip = (activePlayerIsRed ? controlsRedMVC : controlsGreenMVC);
			activeControls.inputMVC.inputTxt.text = String(	constrainMinMax( SpaceRaceBody.INSTANCE.stageToNumline( barMVC.x)).toFixed(1));
		}
		
		// the guess-interval automatically updates when new text is typed in. This method acts as a buffer for typing.
		// without this updateTimer delay, the guess-interval would jump around erratically.
		private function updateGuessNumber( triggerEvent:Event = null):void{
			updateTimer.reset();
			updateTimer.start();
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
		
		
		// --- EVENT DISPATCHING -------------
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
		
		// dispatch a request for a new game
		private function dispatchRequestNewGame(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_NEW_GAME, true));
		}
		
		private function dispatchRequestChangeLevels(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_CHANGE_LEVEL, true));
		}
		
		
		
		// --------- MAIN MENU CONTROLS ---------------
		// this method shows the feedback & next round button that appear after playing a round
		public function showMainMenu():void{
			mainMenuMVC.visible = true;
			t7 = new Tween(mainMenuMVC, "alpha", None.easeNone, 0, 1, 10);
		}
		
		public function hideMainMenu():void{
			mainMenuMVC.visible = false;
		}
		
		public function enableEndGameBtn( triggerEvent:Event = null):void{
			endGameBtn.enabled = true;
			endGameBtn.mouseEnabled = true;
			t8 = new Tween(endGameBtn, "alpha", None.easeNone, endGameBtn.alpha, 1, 10);
		}
		
		public function disableEndGameBtn( triggerEvent:Event = null):void{
			endGameBtn.enabled = false;
			endGameBtn.mouseEnabled = false;
			t9 = new Tween(endGameBtn, "alpha", None.easeNone, endGameBtn.alpha, 0.2, 10);
		}
	}	
	
}
