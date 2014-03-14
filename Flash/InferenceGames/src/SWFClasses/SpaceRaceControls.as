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
		// It includes the buttons, draggable tolerance, cancel button, etc.
		// (It does NOT include the top bar.)
		//
		
		public static var INSTANCE:SpaceRaceControls;
		private var main:*; // to access SpaceRace.as.
		
		private var t1:Tween, t2:Tween, t3:Tween, t4:Tween, t5:Tween, t6:Tween, t7:Tween, t8:Tween, t9:Tween, t10:Tween; 
		//Tweens should never be declaired in a method's scope, because they might be garbage collected before they complete.
		
		public var activePlayerIsHuman:Boolean;	// is the active player the human player?
		private var updateTimer:Timer = new Timer(300, 1); // this timer is the delay between inputting text and the bar updating.
															// For example if a user types '44', the bar doesn't go to 4, then 44.
		private var isDraggingInterval:Boolean = false;	// whether or not the player is dragging the guess - tolerance.
		
		// this method acts like a fake constructor. It has to be called before anything can be done with the SpaceRaceControls.
		public function establish() {
			INSTANCE = this;

			controlsHumanMVC.guessBtn.addEventListener( MouseEvent.CLICK, closeGuessPassHuman);
			controlsHumanMVC.cancelBtn.addEventListener( MouseEvent.CLICK, cancelInputHuman);
			controlsHumanMVC.passBtn.addEventListener( MouseEvent.CLICK, passHuman);
			controlsHumanMVC.inputMVC.okBtn.addEventListener( MouseEvent.CLICK, makeGuess);
			feedbackMVC.newRoundBtnHuman.addEventListener( MouseEvent.CLICK, dispatchRequestNewRound);
			feedbackMVC.visible = false;
			
			draggingControlMVC.addEventListener( MouseEvent.MOUSE_OVER, highlightInterval);
			draggingControlMVC.addEventListener( MouseEvent.MOUSE_OUT, unhighlightInterval);
			draggingControlMVC.addEventListener( MouseEvent.MOUSE_DOWN, startDragFunc);
			barMVC.alpha = 0; // don't show the guessing bar.
			
			controlsHumanMVC.inputMVC.inputTxt.addEventListener( KeyboardEvent.KEY_DOWN, listenForEnter);
			controlsHumanMVC.inputMVC.inputTxt.addEventListener( Event.CHANGE, updateGuessNumber);
			controlsHumanMVC.inputMVC.inputTxt.restrict="0-9."; // only allow numerals in the guessing box
			
			controlsExpertMVC.checkov.visible = false; // Chekov doesn't belong in this game...
			controlsExpertMVC.checkov2.visible = false; // Chekov doesn't belong in this game...
			
			updateTimer.addEventListener(TimerEvent.TIMER, moveGuessToText);
			
			endGameBtn.setClickFunctions( dispatchRequestEndGame, dispatchRequestEndGame);
			disableAndHideEndGameBtn();
			
			//mainMenuMVC.newGameBtn.addEventListener( MouseEvent.CLICK, dispatchRequestNewGame);
			//mainMenuMVC.changeLevelBtn.addEventListener( MouseEvent.CLICK, dispatchRequestChangeLevels);
			mainMenuMVC.visible = false;
		}
		
		// save a reference to SpaceRace.as
		public function setSpaceRace( arg:*):void{
			main = arg;
		}
		
		// --- HUMAN SECTION ------------------------------------------------------------------------
		// makes human controls invisible
		public function hideHuman( triggerEvent:Event = null):void{
			controlsHumanMVC.visible = false;
		}
		
		// makes human controls visible.
		public function showHuman( triggerEvent:Event = null):void{
			controlsHumanMVC.visible = true;
		}
		
		// opens the "primary controls". The human player has two buttons "Guess" and "Pass"
		public function openGuessPassHuman( triggerEvent:Event = null):void{
			controlsHumanMVC.gotoAndPlay("openGuessPass");
			enableEndGameBtn();
		}
		
		// opens the "guessing controls". The human player has two options: Input a guess, or cancel.
		// this also makes the guess-tolerance visible.
		public function openInputCancelHuman( triggerEvent:Event = null):void{
			t1 = new Tween( barMVC, "alpha", None.easeNone, barMVC.alpha, 1, 12); 
			draggingControlMVC.mouseEnabled = true;
			draggingControlMVC.buttonMode = true;
			barMVC.y = SpaceRaceBody.INSTANCE.numberlineY; // - (barMVC.width/2);
			controlsHumanMVC.gotoAndPlay("openInputCancel");
		}
		
		// this method closes the "guessing controls" and causes it to dispatch a guess request.
		public function closeGuessPassHuman( triggerEvent:Event = null):void{
			controlsHumanMVC.gotoAndPlay("closeGuessPass");
			controlsHumanMVC.queueFunction = dispatchHumanGuessRequest;
		}
		
		// cancel the "guessing controls" and return to the "primary controls".
		public function cancelInputHuman( triggerEvent:Event = null):void{
			controlsHumanMVC.gotoAndPlay("closeInputCancel");
			hideFeedback();
			controlsHumanMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnHuman;
		}
		
		// human player passes. Next, the expert player's turn starts.
		public function passHuman( triggerEvent:Event = null):void{
			controlsHumanMVC.gotoAndPlay("closeGuessPass");
			controlsHumanMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnExpert;
			disableEndGameBtn();
		}
		
		
		// --- EXPERT SECTION ------------------------------------------------------------------------
		// To-Do: Should the expert player's controls no longer mirror the human player?
		
		public function hideExpert( triggerEvent:Event = null):void{
			controlsExpertMVC.visible = false;
		}
		
		public function showExpert( triggerEvent:Event = null):void{
			controlsExpertMVC.visible = true;
		}
		
		public function openGuessPassExpert( triggerEvent:Event = null):void{
			controlsExpertMVC.gotoAndPlay("openGuessPass");
		}
		
		public function openInputCancelExpert( triggerEvent:Event = null):void{
			t2 = new Tween( barMVC, "alpha", None.easeNone, barMVC.alpha, 1, 12); 
			draggingControlMVC.mouseEnabled = false;
			draggingControlMVC.buttonMode = false;
			barMVC.y = SpaceRaceBody.INSTANCE.numberlineY;// - (barMVC.width/2);
			controlsExpertMVC.gotoAndPlay("openInputCancel");
		}
		
		public function closeGuessPassExpert( triggerEvent:Event = null):void{
			controlsExpertMVC.gotoAndPlay("closeGuessPass");
			controlsExpertMVC.queueFunction = dispatchExpertGuessRequest;
		}
		
		public function cancelInputExpert( triggerEvent:Event = null):void{
			controlsExpertMVC.gotoAndPlay("closeInputCancel");
			hideFeedback();
			controlsExpertMVC.queueFunction = SpaceRaceBody.INSTANCE.startTurnExpert;
		}
		
		public function passExpert( triggerEvent:Event = null):void{
			controlsExpertMVC.gotoAndPlay("closeGuessPass");
			controlsExpertMVC.queueFunction = SpaceRaceBody.INSTANCE.startDataSampling;
		}
		
		// ---------------------------------------------------------
		// --- GUESSING SECTION ------------------------------------
		
		// checks if the currently entered guess is valid. If it is, it returns true. Otherwise, it returns false & promps the user
		public function validateGuess( triggerEvent:Event = null):Number{
			var activeControls:MovieClip = (activePlayerIsHuman ? controlsHumanMVC : controlsExpertMVC);
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
			
			draggingControlMVC.mouseEnabled = false;	// once the guess has been placed, don't let them drag the tolerance any more
			draggingControlMVC.buttonMode = false;
				
			SpaceRaceBody.INSTANCE.guess = myGuess; // set the guess value.
			SpaceRaceBody.INSTANCE.promptTxt.text = ""; // clear the text field.
			
			var activeControls:MovieClip = (activePlayerIsHuman ? controlsHumanMVC : controlsExpertMVC);
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
		public function showFeedback(headerText:String, bodyText:String, allowNextRound:Boolean, nextRoundButtonText:String = ""):void{
			hideExpert();
			hideHuman();
			feedbackMVC.visible = true;
			t10 = new Tween(feedbackMVC, "alpha", None.easeNone, 0, 1, 10); // fade-in in 10 frames
			
			feedbackMVC.headerTxt.text = headerText;
			feedbackMVC.bodyTxt.text = bodyText;
			
			if( allowNextRound){
				var tf:TextFormat = new TextFormat();	// text format makes it bold
				tf.bold = true;
				feedbackMVC.newRoundBtnHuman.buttonTxt.defaultTextFormat = tf;
				feedbackMVC.newRoundBtnHuman.buttonTxt.text = nextRoundButtonText;
				feedbackMVC.newRoundBtnHuman.visible = true;
				endGameBtn.look = 0;
			} else {
				feedbackMVC.newRoundBtnHuman.visible = false;
				endGameBtn.look = 1;
			}
			
			enableEndGameBtn();
		}
		
		// this method hides the feedback.
		public function hideFeedback( triggerEvent:Event = null):void{
			t3 = new Tween( barMVC, "alpha", None.easeNone, barMVC.alpha, 0, 12); // fade-out in 10 frames
			endGameBtn.look = 0; // the endgame button returns to saying "End Game". Feedback sometimes makes it say "Continue"
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
		
		// this method moves the guess-tolerance to the text's position.
		public function moveGuessToText( triggerEvent:Event = null):void{
			// if the keypress isn't "ENTER", we want to move the guess rect. to the guess' location
			var guessLocation:Number = validateGuess();
			var newX:Number = SpaceRaceBody.INSTANCE.numlineToStage( guessLocation);
			t4 = new Tween( barMVC, "x", Regular.easeOut, barMVC.x, newX, 12); // move the X value of the tolerance bar over 12 frames
		}
		
		// start dragging the tolerance rectangle.
		private function startDragFunc( triggerEvent:MouseEvent):void{
			if( !isDraggingInterval){
				barMVC.startDrag(true, new Rectangle( SpaceRaceBody.INSTANCE.startPoint, SpaceRaceBody.INSTANCE.numberlineY, (SpaceRaceBody.INSTANCE.endPoint - SpaceRaceBody.INSTANCE.startPoint) + 1, 0));
				SpaceRaceBody.INSTANCE.myStage.addEventListener(MouseEvent.MOUSE_MOVE, updateGuess);
				SpaceRaceBody.INSTANCE.myStage.addEventListener( MouseEvent.MOUSE_UP, stopDragFunc);
				isDraggingInterval = true;
			}
		}
		
		// stop dragging the tolerance rectangle.
		private function stopDragFunc( triggerEvent:MouseEvent):void{
			if( isDraggingInterval){
				SpaceRaceBody.INSTANCE.myStage.removeEventListener(MouseEvent.MOUSE_MOVE, updateGuess);
				SpaceRaceBody.INSTANCE.myStage.removeEventListener( MouseEvent.MOUSE_UP, stopDragFunc);
				barMVC.stopDrag();
				updateGuess( triggerEvent);	// allow the player to 'snap' the guess to a specific point with a single click.
				isDraggingInterval = false;
			}
		}
		
		// this method updates the guess text to reflect the position of the draggy-tolerance.
		private function updateGuess( triggerEvent:MouseEvent = null):void{
			var activeControls:MovieClip = (activePlayerIsHuman ? controlsHumanMVC : controlsExpertMVC);
			activeControls.inputMVC.inputTxt.text = String(	constrainMinMax( SpaceRaceBody.INSTANCE.stageToNumline( barMVC.x)).toFixed(1));
		}
		
		// the guess-tolerance automatically updates when new text is typed in. This method acts as a buffer for typing.
		// without this updateTimer delay, the guess-tolerance would jump around erratically.
		private function updateGuessNumber( triggerEvent:Event = null):void{
			updateTimer.reset();
			updateTimer.start();
		}
		
		// given a number on numberline, clip to min and max of range (e.g. 0-100)
		public function constrainMinMax( arg:Number):Number{
			if( arg < (main.minOfRange+0))
				return main.minOfRange;
			if( arg > (main.minOfRange+100))
				return main.minOfRange+100;
			return arg;
		}
		
		//draggingControlMVC runs across the entire numberline. Mousing over it highlights the tolerance bar.
		private function highlightInterval( triggerEvent:Event):void{
			barMVC.gotoAndStop(2);
		}
		private function unhighlightInterval( triggerEvent:Event):void{
			barMVC.gotoAndStop(1);
		}
		
		// move the Tolerance bar to the given position on the numberline
		public function setToleranceBarOnNumberline( axisValue:Number ):void{
			barMVC.x = SpaceRaceBody.INSTANCE.numlineToStage( axisValue);
		}
		
		
		// --- EVENT DISPATCHING -------------
		// dispatch a request for the new round, and hide the 'new round button'
		private function dispatchRequestNewRound(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_NEW_ROUND, true));
			hideFeedback();
		}
		
		// dispatch a request for a expert guess
		private function dispatchExpertGuessRequest(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_GUESS_MODE_EXPERT));
		}
		
		// dispatch a request for a human guess
		private function dispatchHumanGuessRequest(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_GUESS_MODE_HUMAN));
		}
		
		// dispatch a request for a new game
		private function dispatchRequestNewGame(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_NEW_GAME));
		}
		
		private function dispatchRequestChangeLevels(triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_CHANGE_LEVEL));
		}
		
		private function dispatchRequestEndGame( triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_END_GAME));
		}
		
		
		
		// --------- MAIN MENU CONTROLS ---------------
		// this method shows the feedback & next round button that appear after playing a round
		public function showMainMenu():void{
			mainMenuMVC.visible = true;
			SpaceRaceBody.INSTANCE.hideNumberline();
			t7 = new Tween(mainMenuMVC, "alpha", None.easeNone, 0, 1, 10);
		}
		
		public function hideMainMenu():void{
			mainMenuMVC.visible = false;
			SpaceRaceBody.INSTANCE.showNumberline();
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
		
		public function disableAndHideEndGameBtn( triggerEvent:Event = null):void{
			endGameBtn.enabled = false;
			endGameBtn.mouseEnabled = false;
			endGameBtn.alpha = 0;
		}
		
		
		private var level1Func:Function, level2Func:Function, level3Func:Function, level4Func:Function;
		
		// set the text for the Level selection button
		public function setLevelButton( number:int, name:String, stdev:String, tolerance:String, clickFunction:Function){
			var myBtn:MovieClip = mainMenuMVC["level" + number + "Btn"];
			trace(clickFunction);
			myBtn.addEventListener( MouseEvent.CLICK, clickFunction);
			myBtn.nameTxt.text = name;
			myBtn.iqrIntervalTxt.text = "St.Dev. " + stdev + ", Tolerance " + tolerance;
		}
		
		public function lockLevelButton( whichLevel:int):void{
			if( whichLevel < 0 || whichLevel > 4)
				throw new Error("Only 4 levels exist.");
			var myBtn:MovieClip = mainMenuMVC["level" + whichLevel + "Btn"];
			myBtn.enabled = false;
			myBtn.buttonMode = false;
			myBtn.mouseEnabled = false;
			myBtn.alpha = 0.1;
		}
		
		public function unlockLevelButton( whichLevel:int):void{
			if( whichLevel < 0 || whichLevel > 4)
				throw new Error("Only 4 levels exist.");
			var myBtn:MovieClip = mainMenuMVC["level" + whichLevel + "Btn"];
			myBtn.enabled = true;
			myBtn.buttonMode = true;
			myBtn.mouseEnabled = true;
			myBtn.alpha = 1;
		}
		
		// show the check next to the given level in the main menu
		public function checkLevelButton( whichLevel:int):void{
			if( whichLevel < 0 || whichLevel > 4)
				throw new Error("Only 4 levels exist.");
			var myBtn:MovieClip = mainMenuMVC["level" + whichLevel + "Btn"];
			myBtn.checkmarkMVC.visible = true;
		}
		
		// hide the check next to the given level in the main menu
		public function uncheckLevelButton( whichLevel:int):void{
			if( whichLevel < 0 || whichLevel > 4)
				throw new Error("Only 4 levels exist.");
			var myBtn:MovieClip = mainMenuMVC["level" + whichLevel + "Btn"];
			myBtn.checkmarkMVC.visible = false;
		}		
	}	
	
}
