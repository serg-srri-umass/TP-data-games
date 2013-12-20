package {
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.utils.Timer;
	import fl.transitions.Tween;
	import fl.transitions.easing.Elastic;
	import embedded_asset_classes.InferenceEvent;

	import common.ParkMiller;
	
	public class SpaceRaceBody extends MovieClip{
		
		public static var INSTANCE:SpaceRaceBody;
		
		private const IQR_HELP:String = "The bigger the IQR, the more spread out your data will be.";
		private const INTERVAL_HELP:String = "The Interval is the size of your guessing range.";
		
		private var main:*; // the parent of SpaceRaceBody.
		private var myStage:Stage;
		
		// movie clip variables:
		public var numberlineY:Number;			// the Y position of the number line
		public var numberlineLength:Number;		// the length of the number line in px
		public var startPoint:Number;			// the X position of 0 on the number line
		public var endPoint:Number;				// the X pos of 100 on the number line
		public var distributionScaleY:Number;	// the scaleY of the distribution
		
		// datapoint variables:
		public var dataPopSpeed:Number = 3;	// determines how much time occurs between the arrival of data pops.
		public var ticker:int = 0;				// used to handle the animation of data pops 
		private var pm:ParkMiller = new ParkMiller();	// park miller generates a random normal.
		private var dataBladder:Vector.<Number> = new Vector.<Number>(); // holds data points that havent been drawn to screen yet.
		
		//timers
		private var reactivateTimer:Timer = new Timer(900, 1); // half second delay between when the data finishes streaming and the buttons turn back on
		
		
		// ---------- CONSTRUCTOR ---------------
		
		public function SpaceRaceBody(){
			INSTANCE = this;

			numberlineY = start.y;
			startPoint = start.x;
			endPoint = end.x;
			numberlineLength = endPoint - startPoint;
			distributionScaleY = distributionMVC.scaleY;
			
			reactivateTimer.addEventListener(TimerEvent.TIMER, finishDataSampling);
			distributionMVC.addEventListener("animate", revealAnswer);	// when the distribution finishes "wiping" onscreen, it reveals the answer.;
			
			controlsMVC.establish();
		}
		
		public function setStage( arg:Stage):void{
			myStage = arg;
		}
		
		public function setSpaceRace( arg:*):void{
			main = arg;
		}
		
		
		// ---------- MOVIE CLIP MATH ---------------

		// give this method a position on the numberline, and it will return a stage coordinate.
		private function numlineToStage( arg:Number):Number
		{
			var percentageGain:Number = (arg / 100) * numberlineLength;
			return startPoint + percentageGain;
		}

		// give this method a stage coordinate (X) and it will return a position on the numberline.
		private function stageToNumline( arg:Number):Number
		{
			return (arg - startPoint) / numberlineLength * 100;
		}		
		
		// give this method a length, and it will return how many px it is long on the numberline
		private function widthOfNumber( arg:Number):Number
		{
			return numlineToStage( arg) - startPoint;
		}
		
		
		// ---------- TURN FUNCTIONS -----------------
		public function startTurnGreen( triggerEvent:Event = null):void{
			controlsMVC.activePlayerIsRed = false;
			controlsMVC.showGreen();
			controlsMVC.hideRed();
			SpaceRaceTopBar.INSTANCE.setTrim("green");
			controlsMVC.openGuessPassGreen();
			promptTxt.text = "It's " + main.playerNameGreen + "'s turn.";
		}
		
		public function startTurnRed( triggerEvent:Event = null):void{
			controlsMVC.activePlayerIsRed = true;
			controlsMVC.showRed();
			controlsMVC.hideGreen();
			SpaceRaceTopBar.INSTANCE.setTrim("red");
			controlsMVC.openGuessPassRed();
			promptTxt.text = "It's " + main.playerNameRed + "'s turn.";
		}
		
		// this mode gets entered when more data has to be sampled
		public function startDataSampling( triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_SAMPLE, true));
			// this event will tell InferenceGames to start generating data.
			
			if(controlsMVC.activePlayerIsRed){
				controlsMVC.controlsRedMVC.stop();
				controlsMVC.hideGreen();
			} else {
				controlsMVC.controlsGreenMVC.stop();
				controlsMVC.hideRed();
			}			
			promptTxt.text = "Sampling more data...";
		}
		
		// resumes the normal turn structure.
		public function finishDataSampling ( triggerEvent:Event = null):void{
			if(controlsMVC.activePlayerIsRed){
				startTurnGreen();
			} else {
				startTurnRed();
			}
		}
		
		
		// ------------ SAMPLING FUNCTIONS ------------------
		
		public function moveDistributionTo( arg:Number):void{
			distributionMVC.x = numlineToStage( main.median);
		}
		
		// sets the text that says how much sampling is going on
		public function setSampleSizeText( arg:int):void{
			sampleTxt.text = "Sampling " + arg + " at a time.";
		}
				
		// This method performs the actual sampling.
		// both adding it visually to the screen, and returning all the values.
		public function sampleData( triggerEvent:Event = null):Vector.<Number>{
			var outputVector:Vector.<Number> = new Vector.<Number>();
			for( var i:int = 0; i < main.sampleSize; i++){
				var numToPush:Number =  pm.normalWithMeanIQR( main.median, main.iqr);
				dataBladder.push( numToPush);
				outputVector.push( numToPush);
			}
			trace(outputVector);
			return outputVector;
		}
		
		// Checks if any data pops need to be added to the screen. 
		public function handleEnterFrame( triggerEvent:Event):void{
			if (dataBladder.length) // do any pops need to be added?
			{
				if ( ticker % dataPopSpeed == 0)
				{
					var d:DataPop = new DataPop();
					addChild(d);
					d.x = numlineToStage( dataBladder.pop());
					d.y = numberlineY;
					if ( dataBladder.length == 0)
					{
						reactivateTimer.reset();
						reactivateTimer.start();
					}
				}
				ticker++;
			}
		}
		
		
		// ----------- IQR / INTERVAL SECTION ------------
		public function setPossibleIQRs( iqr1:int, iqr2:int = 0, iqr3:int = 0, iqr4:int = 0):void{
			setBarLengthIQR( iqrMVC.barMVC1, iqr1);
			setBarLengthIQR( iqrMVC.barMVC2, iqr2);
			setBarLengthIQR( iqrMVC.barMVC3, iqr3);
			setBarLengthIQR( iqrMVC.barMVC4, iqr4);
			setActiveIQR(iqr1);
		}
		
		// set what possible intervals are allowed this game.
		public function setPossibleIntervals( interval1:int, interval2:int = 0, interval3:int = 0, interval4:int = 0):void{
			setBarLengthInterval( intervalMVC.barMVC1, interval1);
			setBarLengthInterval( intervalMVC.barMVC2, interval2);
			setBarLengthInterval( intervalMVC.barMVC3, interval3);
			setBarLengthInterval( intervalMVC.barMVC4, interval4);
			setActiveInterval(interval1);
		}
		
		// of the predefined possible IQRs, selects the one who matches the given value
		public function setActiveIQR( value:Number):Boolean{
			distributionMVC.width = (numlineToStage(value) - startPoint) * 3.472;  // the distribution is 3.472 times widers than its IQR
			return setActiveBar( iqrMVC, value);
		}
		
		// of the possible predefined intervals, selects the one with the given value
		public function setActiveInterval( value:Number):Boolean{
			return setActiveBar( intervalMVC, value);
		}		
		
		// sets the length of a bar mvc (either interval or IQR) to the given length. If length = 0, hide the bar.
		private function setBarLengthIQR( bar:MovieClip, length:Number):void{
			bar.lengthVar = length; // this lets the bar remember its length.
			if( length <= 0){
				bar.visible = false;
			} else {
				bar.visible = true;
				bar.barMVC.width = widthOfNumber( length);
				bar.numberTxt.x = bar.barMVC.width + 10;
				bar.numberTxt.text = String(length);
			}
		}
		
		// sets the length of a bar mvc (interval) to the given length. If length = 0, hide the bar.
		private function setBarLengthInterval( bar:MovieClip, length:Number):void{
			bar.lengthVar = length; // this lets the bar remember its length.
			if( length <= 0){
				bar.visible = false;
			} else {
				bar.visible = true;
				bar.barMVC.width = widthOfNumber( length * 2);
				bar.numberTxt.x = bar.barMVC.width + 35;
				bar.numberTxt.text = "±" + String(length);
			}
		}
		
		// highlights the correct bar, and deselects the rest
		// container is the movieclip that contaisn the bars.
		// 'value' is the bar that will be selected. Note: if 2 bars are the same length, they will both select. If no bar matches the value, non will select.
		private function setActiveBar( container:MovieClip, value:Number):Boolean{
			var success:Boolean = false; // whether or not the value exists. 
			for( var i:int = 1; i <= 4; i++){
				if( container["barMVC" + i].lengthVar == value){
					container["barMVC" + i].barMVC.gotoAndStop("on");
					container["barMVC" + i].numberTxt.alpha = 1;
					success = true;
				} else {
					container["barMVC" + i].barMVC.gotoAndStop("off");
					container["barMVC" + i].numberTxt.alpha = 0.2;
				}
			}
			return success;
		}
		
		
		// ---------- GUESSING FUNCTIONS --------------
		public function set guess( arg:Number):void{
			main.guess = arg;
		}
		
		// places a guess based on the set guess value. The distribution "wipes" on screen, then shows if it was correct or not.
		public function makeGuess( triggerEvent:Event = null):void
		{			
			trace(main.guess);
			distributionMVC.alpha = 1;
			distributionMVC.gotoAndStop("neutral");
			
			distributionMVC.curveMVC.gotoAndStop("on");
			var bounceTween:Tween = new Tween( distributionMVC, "scaleY", Elastic.easeOut, 0, distributionScaleY, 20);
			revealAnswer();
		}

		// turns the distribution yellow (win) or white (lose), based on the guess.
		private function revealAnswer( triggerEvent:Event = null):void
		{
			if ( Math.abs( main.guess - main.median) <= main.interval){
				distributionMVC.gotoAndStop("won");
				dispatchEvent( new InferenceEvent( InferenceEvent.CORRECT_GUESS, true));
			} else {
				distributionMVC.gotoAndPlay("lost");
				dispatchEvent( new InferenceEvent( InferenceEvent.INCORRECT_GUESS, true));
			}
		}
		
		// this method is a pass-thru. It takes the feedback info, and passes it to the controls where its displayed.
		public function showFeedback( header:String, body:String = ""):void{
			controlsMVC.showFeedback( header, body);
		}
	}
}
/*
package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import common.ParkMiller;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.display.Stage;
	import embedded_asset_classes.SpaceRace;
	
	public class SpaceRaceBody extends MovieClip {
		
		private var main:*; // the parent of SpaceRaceBody.
		private var _inGuessMode:Boolean;
		
		// movie clip variables:
		public var numberlineY:Number;			// the Y position of the number line
		public var numberlineLength:Number;		// the length of the number line in px
		public var startPoint:Number;			// the X position of 0 on the number line
		public var endPoint:Number;				// the X pos of 100 on the number line
		public var distributionScaleY:Number;	// the scaleY of the distribution
		
		// datapoint variables:
		public var dataPopSpeed:Number = 3;	// determines how much time occurs between the arrival of data pops.
		public var ticker:int = 0;				// used to handle the animation of data pops 
		private var pm:ParkMiller = new ParkMiller();	// park miller generates a random normal.
		private var dataBladder:Vector.<Number> = new Vector.<Number>(); // holds data points that havent been drawn to screen yet.
		
		//timers
		private var reactivateTimer:Timer = new Timer(500, 1); // half second delay between when the data finishes streaming and the buttons turn back on
		private var myStage:Stage;
		
		
		// ----------- CONSTRUCTOR FUNCTIONS ----------
		
		public function SpaceRaceBody() {
			numberlineY = start.y;
			startPoint = start.x;
			endPoint = end.x;
			numberlineLength = endPoint - startPoint;
			distributionScaleY = distributionMVC.scaleY;
			//main = parent as SpaceRace;
			
			// event listener section:
			reactivateTimer.addEventListener(TimerEvent.TIMER, reactivateButtons);
			distributionMVC.addEventListener("animate", revealAnswer);	// when the distribution finishes "wiping" onscreen, it reveals the answer.;
			
			// disable the mouse on objects that should ignore it:
			dataTxt.mouseChildren = false;
			guessTxt.mouseChildren = false;
			guessTxt.mouseEnabled = false;
			dataTxt.mouseEnabled = false;
			distributionMVC.mouseChildren = false;
			distributionMVC.mouseEnabled = false;
			guessCursorMVC.mouseEnabled = false;
		}
		
		public function setStage( arg:Stage):void{
			myStage = arg;
		}
		
		public function setSpaceRace( arg:*):void{
			main = arg;
		}
		
		// ---------- MOVIE CLIP MATH ---------------

		// give this method a position on the numberline, and it will return a stage coordinate.
		private function numlineToStage( arg:Number):Number
		{
			var percentageGain:Number = (arg / 100) * numberlineLength;
			return startPoint + percentageGain;
		}

		// give this method a stage coordinate (X) and it will return a position on the numberline.
		private function stageToNumline( arg:Number):Number
		{
			return (arg - startPoint) / numberlineLength * 100;
		}		
		
		
		// ------------ SAMPLING FUNCTIONS ------------------
		
		public function moveDistributionTo( arg:Number):void{
			distributionMVC.x = numlineToStage( main.median);
		}
		
		public function setSampleSize( arg:int):void{
			dataTxt.txt.text = "Sample " + arg + " dot";
			if(arg > 1)
				dataTxt.txt.text += "s";
		}
				
		// samples data of the chosen sample size.
		public function sampleData( triggerEvent:Event = null):Vector.<Number>{
			var outputVector:Vector.<Number> = new Vector.<Number>();
			for( var i:int = 0; i < main.sampleSize; i++){
				var numToPush:Number =  pm.normalWithMeanIQR( main.median, main.iqr);
				dataBladder.push( numToPush);
				outputVector.push( numToPush);
			}
			deactivateButtons();
			dispatchEvent( new Event( InferenceEvent.SAMPLE, true));
			return outputVector;
		}
		
		// overdraw causes the distribution to spring up, red, as an incorrect. Lose 1 life.
		public function overdraw( triggerEvent:Event = null):void{
			deactivateButtons();
			dataBtn.enabled = false; // the button needs to be disabled, or else it will go to the '+' state.
			dataBtn.gotoAndStop(4);	// red screen
			dataBtn.alpha = 1;
			dataTxt.alpha = 1;
			dataTxt.txt.text = "Too many dots!";	// should say something else?
			dispatchEvent( new InferenceEvent( InferenceEvent.OVERDRAW, true));
			forceFailGuess( triggerEvent); // lose life, when fail guess.
		}
		
		// Checks if any data pops need to be added to the screen. 
		public function handleEnterFrame( triggerEvent:Event):void{
			if (dataBladder.length) // do any pops need to be added?
			{
				if ( ticker % dataPopSpeed == 0)
				{
					var d:DataPop = new DataPop();
					addChild(d);
					d.x = numlineToStage( dataBladder.pop());
					d.y = numberlineY;
					if ( dataBladder.length == 0)
					{
						reactivateTimer.reset();
						reactivateTimer.start();
					}
				}
				ticker++;
			}
		}
		
		
		// ---------------- SAMPLE & GUESS BUTTONS ----------------------
		
		// temporarily disables the buttons. When canEscape is true, guess button becomes 'escape' prompt
		public function deactivateButtons( triggerEvent:Event = null, canEscape:Boolean = false):void
		{
			dataBtn.mouseEnabled = false;
			guessBtn.mouseEnabled = false;
			
			// safety net that prevents buttons from not disappearing properly.;
			dataBtn.removeEventListener( Event.ENTER_FRAME, appearInner);
			dataTxt.removeEventListener( Event.ENTER_FRAME, appearInner);
			guessTxt.removeEventListener( Event.ENTER_FRAME, appearInner);
			guessBtn.removeEventListener( Event.ENTER_FRAME, appearInner);

			dataBtn.alpha = 0.1;
			dataTxt.alpha = 0.1;
			
			if( !canEscape){
				guessBtn.alpha = 0.1;
				guessTxt.alpha = 0.1;
				//guessTxt.txt.text = "Make a guess";
			} else {
				guessBtn.alpha = 0.1;
				guessTxt.alpha = 0.6;
				guessTxt.txt.text = "[Esc] to cancel";
			}
		}
		
		// reactivates the disabled buttons.
		public function reactivateButtons(triggerEvent:Event = null):void
		{
			dataBtn.mouseEnabled = true;
			dataBtn.enabled = true;
			dataBtn.gotoAndStop(1);
			guessBtn.mouseEnabled = true;

			appear( dataTxt);
			appear( dataBtn);
			appear( guessBtn);
			appear( guessTxt);
			guessTxt.txt.text = "Make a guess";
		}
		
		// ------------ MODE SWITCHING --------------------
		
		// switches to guess mode, reveals the guess cursor, hides the mouse.
		public function switchToGuessMode(triggerEvent:Event = null):void
		{
			_inGuessMode = true;
			main.dispatchEvent( new InferenceEvent( InferenceEvent.ENTER_GUESS_MODE, true));
			Mouse.hide();
			appear( guessCursorMVC, 0);
			myStage.addEventListener( MouseEvent.MOUSE_MOVE, moveCursorToMousePosition);
			myStage.addEventListener( MouseEvent.MOUSE_DOWN, makeGuess);
			myStage.addEventListener( KeyboardEvent.KEY_DOWN, handleKeys);	
		}

		// switches to normal mode, with guess cursor hidden and mouse showing.
		public function switchToMouseMode(triggerEvent:Event = null):void
		{
			_inGuessMode = false;
			if(guessCursorMVC.visible) // only dispatch the event when truely switching to mouse mode
				main.dispatchEvent( new InferenceEvent( InferenceEvent.ENTER_MOUSE_MODE, true));
			
			Mouse.show();
			guessCursorMVC.visible = false;
			if(!myStage)	return;
			
			myStage.removeEventListener( MouseEvent.MOUSE_MOVE, moveCursorToMousePosition);
			myStage.removeEventListener( MouseEvent.MOUSE_DOWN, makeGuess);
			myStage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
		}
		
		public function isInGuessMode():Boolean{
			return _inGuessMode;
		}
		
		// -------------- APPEAR / DISAPPEAR DISPLAY OBJECTS ---------------------
		
		// causes a movieclip to fade in
		private function appear( mvc:DisplayObject, startingAlpha:Number = -1):void
		{
			mvc.visible = true;
			if ( startingAlpha >= 0)
			{
				mvc.alpha = startingAlpha;
			}
			mvc.removeEventListener(Event.ENTER_FRAME, disappearInner);
			mvc.addEventListener(Event.ENTER_FRAME, appearInner);
		}
		private function appearInner(triggerEvent:Event):void
		{
			triggerEvent.target.alpha +=  0.1;
			if (triggerEvent.target.alpha >= 1)
			{
				triggerEvent.target.removeEventListener( triggerEvent.type, appearInner);
			}
		}

		// causes a movieclip to fade out
		private function disappear( mvc:DisplayObject, startingAlpha:Number = -1):void
		{
			mvc.visible = true;
			if ( startingAlpha >= 0)
			{
				mvc.alpha = startingAlpha;
			}
			mvc.removeEventListener(Event.ENTER_FRAME, appearInner);
			mvc.addEventListener(Event.ENTER_FRAME, disappearInner);
		}
		
		// called every frame, during disappear.
		private function disappearInner(triggerEvent:Event):void
		{
			triggerEvent.target.alpha -=  0.1;
			if (triggerEvent.target.alpha <= -0)
			{
				triggerEvent.target.removeEventListener( triggerEvent.type, disappearInner);
			}
		}
		
		// ---------- SETTERS FOR IQR AND INTERVAL ------------------
		
		// sets the length of the IQR
		public function setIQR( arg:Number, hiddenIQR:Boolean):void{
			var myTween:Tween = new Tween(iqrLineMVC, "width", Elastic.easeOut,iqrLineMVC.width, (numlineToStage(arg) - startPoint), 20);
			distributionMVC.width = (numlineToStage(arg) - startPoint) * 3.472;  // the distribution is 3.472 times widers than its IQR
			
			if( !hiddenIQR){
				iqrLineMVC.visible = true;
				iqrTxt.text = arg.toString();
			} else {
				iqrLineMVC.visible = false;
				iqrTxt.text = "?";
			}
		}
		
		public function setInterval( arg:Number, hiddenInterval:Boolean):void{
			var myTween:Tween = new Tween(intervalLineMVC,"width",Elastic.easeOut,intervalLineMVC.width,(numlineToStage(arg) - startPoint) * 2,20);
			guessCursorMVC.cursor.width = (numlineToStage(arg) - startPoint) * 2;
			
			if( !hiddenInterval){
				intervalLineMVC.visible = true;
				guessCursorMVC.cursor.alpha = 1;
				intervalTxt.text = arg.toString();
			} else {
				intervalLineMVC.visible = false;
				guessCursorMVC.cursor.alpha = 0;
				intervalTxt.text = "?";
			}
		}
		
		
		// ---------------- GUESSING FUNCTIONS ---------------------
		
		// places a guess based on the cursor's position. The distribution "wipes" on screen, then shows if it was correct or not.
		private function makeGuess(triggerEvent:Event):void
		{
			deactivateButtons();
			
			main.guess = Number(guessCursorMVC.pos.text);
			Mouse.show();

			// show the underlying distribution
			distributionMVC.gotoAndStop("neutral");
			distributionMVC.alpha = 1;
			
			// wipe direction is based on where the median was. 
			if (main.median < 50)
			{
				distributionMVC.curveMVC.gotoAndPlay("enterRight");
			}
			else
			{
				distributionMVC.curveMVC.gotoAndPlay("enterLeft");
			}

			if(!myStage)	return;
			myStage.removeEventListener( MouseEvent.MOUSE_DOWN, makeGuess);
			myStage.removeEventListener( MouseEvent.MOUSE_MOVE, moveCursorToMousePosition);
			myStage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
		}
		
		// this method guesses incorrectly and makes the distribution pop up in red, without "wiping" onscreen. For when you overdraw (the expert guesses)
		private function forceFailGuess(triggerEvent:Event):void
		{
			main.guess = -100;
			Mouse.show();
			
			distributionMVC.alpha = 1;
			distributionMVC.gotoAndStop("neutral");
			
			distributionMVC.curveMVC.gotoAndStop("on");
			revealAnswer(triggerEvent, false);
			var failTween:Tween = new Tween( distributionMVC, "scaleY", Elastic.easeOut, 0, distributionScaleY, 20);
		}

		// hides the distribution, and returns to mouse mode
		private function clearGraph( triggerEvent:MouseEvent):void
		{
			myStage.removeEventListener( MouseEvent.MOUSE_DOWN, clearGraph);
			switchToMouseMode();
			reactivateButtons( triggerEvent);
			appear(iqrLineMVC);
		}

		// turns the distribution red (lose) or green (lose), based on the guess. Lose life if wrong, gain score if right.
		private function revealAnswer( triggerEvent:Event, missedGuess:Boolean = true):void
		{
			trace(main.guess, main.median, main.interval);
			if ( Math.abs( main.guess - main.median) <= main.interval)
			{
				distributionMVC.gotoAndPlay(	missedGuess ? "win" : "won");
				main.earnPoint();
				main.dispatchEvent( new InferenceEvent( InferenceEvent.CORRECT_GUESS, true));
			}
			else
			{
				distributionMVC.gotoAndPlay(	missedGuess ? "lose" : "lost");
				main.loseLife();
				if( missedGuess)
					main.loseLife(); // missing a guess costs 2 life
					
				main.dispatchEvent( new InferenceEvent( InferenceEvent.INCORRECT_GUESS, true));
			}
			myStage.addEventListener(MouseEvent.MOUSE_DOWN, finishRound);
		}
		
		// ------------- MISC ----------------------
		
		// handles the movement of the guess cursor.
		public function moveCursorToMousePosition( triggerEvent:MouseEvent):void
		{
			var goingPoint:Number;
			if (triggerEvent.stageX < startPoint)	// dont let the cursor go below 0 or above 100
			{
				goingPoint = startPoint; // 0
			}
			else if (triggerEvent.stageX > endPoint)
			{
				goingPoint = endPoint; // 100
			}
			else
			{
				goingPoint = triggerEvent.stageX; // mouse X
			}
			
			guessCursorMVC.x = goingPoint;
			guessCursorMVC.pos.text = stageToNumline(goingPoint).toFixed(1); // text above guess cursor
		}
		
		private function handleKeys( triggerEvent:KeyboardEvent):void{
			if(triggerEvent.keyCode == 27){ 	// escape
				switchToMouseMode();
				reactivateButtons( triggerEvent);
			}
		}
		
		// goes on to a new round
		private function finishRound( triggerEvent:MouseEvent):void
		{
			myStage.removeEventListener( MouseEvent.MOUSE_DOWN, finishRound);

			disappear( distributionMVC);
			disappear( guessCursorMVC);
			main.newRoundTimer.reset();
			
			if( main.life <= 0)
				main.dispatchEvent( new InferenceEvent( InferenceEvent.LOSE_GAME, true));
			else if( main.score >= main.WINNING_SCORE)
				main.dispatchEvent( new InferenceEvent( InferenceEvent.WIN_GAME, true));
			else
				main.newRoundTimer.start();
				
			switchToMouseMode();
		}
	}
	
}*/
