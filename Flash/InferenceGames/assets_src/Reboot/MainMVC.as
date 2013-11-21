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
	
	
	public class MainMVC extends MovieClip {
		
		public var main:GameScreen;
		
		// movie clip variables:
		public var numberlineY:Number;			// the Y position of the number line
		public var numberlineLength:Number;	// the length of the number line in px
		public var startPoint:Number;			// the X position of 0 on the number line
		public var endPoint:Number;			// the X pos of 100 on the number line
		public var distributionScaleY:Number;	// the scaleY of the distribution
		
		// datapoint variables:
		public var dataPopSpeed:Number = 3;	// determines how much time occurs between the arrival of data pops.
		public var ticker:int = 0;				// used to handle the animation of data pops 
		public var pm:ParkMiller = new ParkMiller();	// park miller generates a random normal.
		
		//timers
		public var reactivateTimer:Timer = new Timer(500, 1); // half second delay between when the data finishes streaming and the buttons turn back on

		
		public function MainMVC() {
			numberlineY = start.y;
			startPoint = start.x;
			endPoint = end.x;
			numberlineLength = endPoint - startPoint;
			distributionScaleY = distributionMVC.scaleY;
			main = parent as GameScreen;
			
			// event listener section:
			reactivateTimer.addEventListener(TimerEvent.TIMER, reactivateButtons);
			distributionMVC.addEventListener("animate", revealAnswer);	// when the distribution finishes "wiping" onscreen, it reveals the answer.;
			
			// disable the mouse on objects that should ignore it:
			sampleTxt.mouseChildren = false;
			guessTxt.mouseChildren = false;
			guessTxt.mouseEnabled = false;
			sampleTxt.mouseEnabled = false;
			distributionMVC.mouseChildren = false;
			distributionMVC.mouseEnabled = false;
			guessCursorMVC.mouseEnabled = false;
		}
		
		// ---------- MOVIE CLIP MATH ---------------

		// give this method a position on the numberline, and it will return a stage coordinate.
		public function numlineToStage( arg:Number):Number
		{
			var percentageGain:Number = (arg / 100) * numberlineLength;
			return startPoint + percentageGain;
		}

		// give this method a stage coordinate (X) and it will return a position on the numberline.
		public function stageToNumline( arg:Number):Number
		{
			return (arg - startPoint) / numberlineLength * 100;
		}
		
		
		
		
		// ------------ SAMPLING FUNCTIONS ------------------
		
		public function moveDistributionTo( arg:Number):void{
			distributionMVC.x = numlineToStage( main.median);
		}
		
		public function setSampleSize( arg:int):void{
			sampleTxt.sampleTxt.text = "Sample " + arg + " dot";
			if(arg > 1)
				sampleTxt.sampleTxt.text += "s";
		}
		
		private var dataBladder:Vector.<Number> = new Vector.<Number>();
		
		// samples data of the chosen sample size.
		public function sampleData( triggerEvent:Event = null):Vector.<Number>{
			//dataPointsToSample += main.sampleSize;
			var outputVector:Vector.<Number> = new Vector.<Number>();
			for( var i:int = 0; i < main.sampleSize; i++){
				var numToPush:Number =  pm.normalWithMeanIQR( main.median, main.iqr);
				dataBladder.push( numToPush);
				outputVector.push( numToPush);
			}
			deactivateButtons();
			return outputVector;
		}
		
		public function overdraw( triggerEvent:Event = null):void{
			deactivateButtons();
			dataBtn.enabled = false; // the button needs to be disabled, or else it will go to the '+' state.
			dataBtn.gotoAndStop(4);	// red screen
			dataBtn.alpha = 1;
			sampleTxt.alpha = 1;
			sampleTxt.sampleTxt.text = "Too many dots!";	// should say something else?
			forceFailGuess( triggerEvent);
		}
		
		// Checks if any data pops need to be added to the screen. 
		public function handlePops():void{
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
		
		// temporarily disables the buttons. When tweakGB is true, guess button becomes 'escape' prompt
		public function deactivateButtons( tweakGuessButton:Boolean = false):void
		{
			dataBtn.mouseEnabled = false;
			guessBtn.mouseEnabled = false;
			
			// safety net that prevents buttons from not disappearing properly.;
			dataBtn.removeEventListener( Event.ENTER_FRAME, appearInner);
			sampleTxt.removeEventListener( Event.ENTER_FRAME, appearInner);
			guessBtn.removeEventListener( Event.ENTER_FRAME, appearInner);

			dataBtn.alpha = 0.1;
			sampleTxt.alpha = 0.1;
			
			if( !tweakGuessButton){
				guessBtn.alpha = 0.1;
				guessTxt.alpha = 0.1;
				//guessTxt.sampleTxt.text = "Make a guess";
			} else {
				guessBtn.alpha = 0.1;
				guessTxt.alpha = 0.6;
				guessTxt.sampleTxt.text = "[Esc] to cancel";
			}
		}
		
		// reactivates the disabled buttons.
		public function reactivateButtons(triggerEvent:Event = null):void
		{
			dataBtn.mouseEnabled = true;
			dataBtn.enabled = true;
			dataBtn.gotoAndStop(1);
			guessBtn.mouseEnabled = true;

			appear( sampleTxt);
			appear( dataBtn);
			appear( guessBtn);
			appear( guessTxt);
			guessTxt.sampleTxt.text = "Make a guess";
		}
		
		// ------------ MODE SWITCHING --------------------
		
		// switches to guess mode, reveals the guess cursor, hides the mouse.
		public function switchToGuessMode(triggerEvent:Event = null):void
		{
			main.dispatchEvent( new InferenceEvent( InferenceEvent.ENTER_GUESS_MODE));
			
			Mouse.hide();
			appear( guessCursorMVC, 0);
			stage.addEventListener( MouseEvent.MOUSE_MOVE, doCursor);
			stage.addEventListener( MouseEvent.MOUSE_DOWN, makeGuess);
			stage.addEventListener( KeyboardEvent.KEY_DOWN, handleKeys);	
		}

		// switches to normal mode, with guess cursor hidden and mouse showing.
		public function switchToMouseMode(triggerEvent:Event = null):void
		{
			if(guessCursorMVC.visible) // only dispatch the event when truely switching to mouse mode
				main.dispatchEvent( new InferenceEvent( InferenceEvent.ENTER_MOUSE_MODE));
			
			Mouse.show();
			guessCursorMVC.visible = false;
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, doCursor);
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, makeGuess);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
		}
		
		// -------------- APPEAR / DISAPPEAR DISPLAY OBJECTS ---------------------
		
		// causes a movieclip to fade in
		public function appear( mvc:DisplayObject, startingAlpha:Number = -1):void
		{
			mvc.visible = true;
			if ( startingAlpha >= 0)
			{
				mvc.alpha = startingAlpha;
			}
			mvc.removeEventListener(Event.ENTER_FRAME, disappearInner);
			mvc.addEventListener(Event.ENTER_FRAME, appearInner);
		}
		public function appearInner(triggerEvent:Event):void
		{
			triggerEvent.target.alpha +=  0.1;
			if (triggerEvent.target.alpha >= 1)
			{
				triggerEvent.target.removeEventListener( triggerEvent.type, appearInner);
			}
		}

		// causes a movieclip to fade out
		public function disappear( mvc:DisplayObject, startingAlpha:Number = -1):void
		{
			mvc.visible = true;
			if ( startingAlpha >= 0)
			{
				mvc.alpha = startingAlpha;
			}
			mvc.removeEventListener(Event.ENTER_FRAME, appearInner);
			mvc.addEventListener(Event.ENTER_FRAME, disappearInner);
		}
		
		public function disappearInner(triggerEvent:Event):void
		{
			triggerEvent.target.alpha -=  0.1;
			if (triggerEvent.target.alpha <= -0)
			{
				triggerEvent.target.removeEventListener( triggerEvent.type, disappearInner);
			}
		}
		
		// ---------- SETTERS FOR IQR AND INTERVAL ------------------
		
		// sets the length of the IQR
		public function setIQR( arg:Number, secret:Boolean):void{
			var myTween:Tween = new Tween(iqrLineMVC,"width",Elastic.easeOut,iqrLineMVC.width,(numlineToStage(arg) - startPoint),20);
			distributionMVC.width = (numlineToStage(arg) - startPoint) * 3.472;
			
			if( !secret){
				iqrLineMVC.visible = true;
				iqrTxt.text = arg.toString();
			} else {
				// in secret mode, the IQR is hidden
				iqrLineMVC.visible = false;
				iqrTxt.text = "?";
			}
		}
		
		public function setInterval( arg:Number, secret:Boolean):void{
			var myTween:Tween = new Tween(intervalLineMVC,"width",Elastic.easeOut,intervalLineMVC.width,(numlineToStage(arg) - startPoint) * 2,20);
			guessCursorMVC.cursor.width = (numlineToStage(arg) - startPoint) * 2;
			
			if( !secret){
				intervalLineMVC.visible = true;
				guessCursorMVC.cursor.alpha = 1;
				intervalTxt.text = arg.toString();
			} else {
				// in secret mode, the interval is hidden
				intervalLineMVC.visible = false;
				guessCursorMVC.cursor.alpha = 0;
				intervalTxt.text = "?";
			}
		}
		
		
		// ---------------- GUESSING FUNCTIONS ---------------------
		
		// gets the guess, as per the text above the interval
		public function getGuess():Number
		{
			return Number(guessCursorMVC.pos.text); 
		}
		
		// places a guess based on the cursor's position. The distribution "wipes" on screen, then shows if it was correct or not.
		public function makeGuess(triggerEvent:Event):void
		{
			deactivateButtons();
			
			main.guess = getGuess();
			Mouse.show();

			// show the underlying distribution
			distributionMVC.gotoAndStop("neutral");
			distributionMVC.alpha = 1;
			if (main.median < 50)
			{
				distributionMVC.curveMVC.gotoAndPlay("enterRight");
			}
			else
			{
				distributionMVC.curveMVC.gotoAndPlay("enterLeft");
			}

			stage.removeEventListener( MouseEvent.MOUSE_DOWN, makeGuess);
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, doCursor);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
		}
		
		// this method guesses incorrectly and makes the distribution pop up in red, without "wiping" onscreen
		public function forceFailGuess(triggerEvent:Event):void
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
		public function clearGraph( triggerEvent:MouseEvent):void
		{
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, clearGraph);
			switchToMouseMode();
			reactivateButtons( triggerEvent);
			appear(iqrLineMVC);//iqrLineMVC.addEventListener(Event.ENTER_FRAME, appear);
		}

		// turns the distribution red (lose) or green (lose), based on the guess
		function revealAnswer( triggerEvent:Event, missedGuess:Boolean = true):void
		{
			trace(main.guess, main.median, main.interval);
			if ( Math.abs( main.guess - main.median) <= main.interval)
			{
				distributionMVC.gotoAndPlay(	missedGuess ? "win" : "won");
				main.earnPoint();
				main.dispatchEvent( new InferenceEvent( InferenceEvent.CORRECT_GUESS));
			}
			else
			{
				distributionMVC.gotoAndPlay(	missedGuess ? "lose" : "lost");
				main.loseLife();
				if( missedGuess)
					main.loseLife(); // missing a guess costs 2 life
					
				main.dispatchEvent( new InferenceEvent( InferenceEvent.INCORRECT_GUESS));
			}
			stage.addEventListener(MouseEvent.MOUSE_DOWN, finishRound);
		}
		
		// ------------- MISC ----------------------
		
		// handles the movement of the guess cursor.
		public function doCursor( triggerEvent:MouseEvent):void
		{
			var goingPoint:Number;
			if (triggerEvent.stageX < startPoint)
			{
				goingPoint = startPoint;
			}
			else if (triggerEvent.stageX > endPoint)
			{
				goingPoint = endPoint;
			}
			else
			{
				goingPoint = triggerEvent.stageX;

			}
			guessCursorMVC.x = goingPoint;
			guessCursorMVC.pos.text = stageToNumline(goingPoint).toFixed(1);
		}
		
		public function handleKeys( triggerEvent:KeyboardEvent):void{
			if(triggerEvent.keyCode == 27){ 	// escape
				switchToMouseMode();
				reactivateButtons( triggerEvent);
			}
		}
		
		// goes on to a new round
		public function finishRound( triggerEvent:MouseEvent):void
		{
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, finishRound);

			disappear( distributionMVC);
			disappear( guessCursorMVC);
			main.newRoundTimer.reset();
			
			if( main.life <= 0)
				main.dispatchEvent( new InferenceEvent( InferenceEvent.LOSE_GAME));
			else if( main.score >= main.WINNING_SCORE)
				main.dispatchEvent( new InferenceEvent( InferenceEvent.WIN_GAME));
			else
				main.newRoundTimer.start();
				
			switchToMouseMode();
		}
	}
	
}
