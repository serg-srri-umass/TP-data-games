package 
{

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

	public class GameScreen extends MovieClip
	{

		// -----------------
		// --- VARIABLES ---
		// -----------------

		// movie clip variables:
		private var numberlineY:Number;			// the Y position of the number line
		private var numberlineLength:Number;	// the length of the number line in px
		private var startPoint:Number;			// the X position of 0 on the number line
		private var endPoint:Number;			// the X pos of 100 on the number line
		private var distributionScaleY:Number;	// the scaleY of the distribution

		// datapoint variables:
		private var dataPopSpeed:Number = 3;	// determines how much time occurs between the arrival of data pops.
		private var ticker:int = 0;				// used to handle the animation of data pops 
		private var dataPointsSampled:int = 0,dataPointsToSample:int = 0;
		private var pm:ParkMiller = new ParkMiller();	// park miller generates a random normal.

		// round & guessing variables:
		private var _median:Number;			// the _median of the distribution that is currently being sampled.
		private var _guess:Number = -100; 	// The guess #. Ranges from 0 - 100. 
		private var _interval; 				// GUESS INTERVAL
		private var _IQR:int; 				// GUESS IQR
		private var _sampleSize:int;		// how many samples are drawn each time the sample button is clicked.

		// timers:
		private var reactivateTimer:Timer = new Timer(500, 1); // half second delay between when the data finishes streaming and the buttons turn back on
		private var newRoundTimer:Timer = new Timer(500, 1); // one second delay between new round

		// scoring variables:
		private const STARTING_LIFE:int = 3;
		private var _life:int = STARTING_LIFE;
		private var _score:int = 0, _printedScore:int = 0;

		// ----------------------
		// --- PUBLIC METHODS ---
		// ----------------------

		// constructor
		public function GameScreen()
		{
			numberlineY = start.y;
			startPoint = start.x;
			endPoint = end.x;
			numberlineLength = endPoint - startPoint;
			distributionScaleY = distributionMVC.scaleY;

			// event listener section:
			this.addEventListener( Event.ENTER_FRAME, handleEnterFrame);
			reactivateTimer.addEventListener(TimerEvent.TIMER, reactivateButtons);
			dataBtn.addEventListener(MouseEvent.CLICK, clickSampleButton);	// click the sample more data button;
			guessBtn.addEventListener(MouseEvent.CLICK, clickGuessButton);		// click the guess button;
			distributionMVC.addEventListener("animate", revealAnswer);	// when the distribution finishes "wiping" onscreen, it reveals the answer.;
			newRoundTimer.addEventListener(TimerEvent.TIMER, startNewRound);	// when the new round timer completes, the new round starts.;

			// disable the mouse on objects that should ignore it:
			sampleTxt.mouseChildren = false;
			sampleTxt.mouseEnabled = false;
			distributionMVC.mouseChildren = false;
			distributionMVC.mouseEnabled = false;
			guessCursorMVC.mouseEnabled = false;

			// PROXY SECTION. REMOVE ALL THIS BEFORE IT GOES LIVE.
			startNewRound(); 
			addEventListener( InferenceEvent.SAMPLE, doTheSamples);
			backBtn.addEventListener( MouseEvent.CLICK, newGame);
		}
		
		// ----------- NEW ROUND / NEW GAME --------------
		
		// start a new round. Give it an IQR, interval, and the distribution median.
		public function newRound( iqr:int, interval:int, median:Number, sampleSize:int):void
		{
			switchToMouseMode(); // ensure the round starts in mouse-mode

			_median = median;
			this.sampleSize = sampleSize;
			setIQR(iqr);
			setInterval(interval);
			
			trace("The median is: " + median);
			distributionMVC.x = numlineToStage(_median);
		}
		
		// start a new game.
		public function newGame( triggerEvent:Event = null):void{
			switchToMouseMode(); // ensure the game starts in mouse-mode
			resetScore();
			resetLife();
			startNewRound(); // proxy
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
		
		
		// ----------- IQR / INTERVAL / MEDIAN -------------
		
		public function get iqr():int{			return _IQR;	}
		public function get interval():int{		return _interval;	}
		public function get median():Number{	return _median;		}
		
		// ---------- DATA SAMPLING ------------- 
		
		public function get sampleSize():int{	return _sampleSize;	}
		
		public function set sampleSize( arg:int):void{
			_sampleSize = arg;
			sampleTxt.sampleTxt.text = "Sample " + arg + " dot";
			if(_sampleSize > 1)
				sampleTxt.sampleTxt.text += "s";
		}
		
		// samples data of the chosen sample size.
		public function sampleData( triggerEvent:Event = null):void{
			dataPointsToSample += _sampleSize;
			deactivateButtons();
		}
		
		// call this method when the player attempts to draw too much data
		public function overdraw( triggerEvent:Event = null):void{
			deactivateButtons();
			dataBtn.enabled = false; // the button needs to be disabled, or else it will go to the 'click' state.
			dataBtn.gotoAndStop(4);	// red screen
			dataBtn.alpha = 1;
			sampleTxt.alpha = 1;
			sampleTxt.sampleTxt.text = "Too many dots!";	// should say something else?
			forceFailGuess( triggerEvent);
			dispatchEvent( new InferenceEvent( InferenceEvent.OVERDRAW));
		}
		
		// ----------- SCORING ------------------
		
		// lose a point of "life", when you guess incorrectly, or overdraw.
		public function loseLife( triggerEvent:Event = null):void{
			lifeMVC.lostLifeMVC.hurtScoreTxt.text = _life;
			_life--;
			lifeMVC.myLifeTxt.text = _life;
			lifeMVC.gotoAndPlay(1);
			dispatchEvent( new InferenceEvent( InferenceEvent.LOSE_LIFE));
		}
		
		// earn X points. This is pretty useless at the moment, because the score system shouldn't work like this.
		public function earnScore( score:int):void{
			_score += score;
			myScoreMVC.gotoAndPlay(1);
			dispatchEvent( new InferenceEvent( InferenceEvent.EARN_POINT));
		}
		
		// reset the score to its starting value.
		public function resetScore():void{
			_score = 0;
			_printedScore = 0;
			myScoreMVC.myScoreMVC.myScoreTxt.text = "00000"; // buffer = 5;
		}
		
		// reset the life to its starting value
		public function resetLife():void{
			_life = STARTING_LIFE;
			lifeMVC.myLifeTxt.text = _life;
			lifeMVC.lostLifeMVC.hurtScoreTxt.text = _life;
		}
		

		// -----------------------
		// --- PRIVATE METHODS ---
		// -----------------------

		// ------------ MODE SWITCHING --------------------
		
		// switches to guess mode, reveals the guess cursor, hides the mouse.
		private function switchToGuessMode(triggerEvent:Event = null):void
		{
			dispatchEvent( new InferenceEvent( InferenceEvent.ENTER_GUESS_MODE));
			
			Mouse.hide();
			appear( guessCursorMVC, 0);
			stage.addEventListener( MouseEvent.MOUSE_MOVE, doCursor);
			stage.addEventListener( MouseEvent.MOUSE_DOWN, makeGuess);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
		}

		// switches to normal mode, with guess cursor hidden and mouse showing.
		private function switchToMouseMode(triggerEvent:Event = null):void
		{
			if(guessCursorMVC.visible) // only dispatch the event when truely switching to mouse mode
				dispatchEvent( new InferenceEvent( InferenceEvent.ENTER_MOUSE_MODE));
			
			Mouse.show();
			guessCursorMVC.visible = false;
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, doCursor);
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, makeGuess);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
		}
		
		
		// ---------------- ON ENTER FRAME --------------
		// the methods in this section are called every frame (@24 fps)
		
		private function handleEnterFrame(triggerEvent:Event):void
		{
			handleScore();
			handlePops();
		}
		
		// Checks if any data pops need to be added to the screen. 
		private function handlePops():void{
			if (dataPointsToSample > dataPointsSampled) // do any pops need to be added?
			{
				if ( ticker % dataPopSpeed == 0)
				{
					var d:DataPop = new DataPop();
					addChild(d);
					d.x = numlineToStage(pm.normalWithMeanIQR(_median,_IQR));
					d.y = numberlineY;
					dataPointsSampled++;
					if (dataPointsSampled == dataPointsToSample)
					{
						reactivateTimer.reset();
						reactivateTimer.start();
					}
				}
				ticker++;
			}
		}
		
		// Checks if the score is higher than what's currently on screen. If so, bump it up.
		private function handleScore():void{
			if( _printedScore < _score){
				_printedScore += ( (_score - _printedScore) / 4 ) + 1;
				if(_printedScore > _score){
					_printedScore = _score;
				}
				var rawScore:String = _printedScore.toString();
				var buffer:String = "";
				var runs:int = 5 - rawScore.length;
				for( var i:int = 0; i < runs; i++){
					buffer += "0";
				}
				myScoreMVC.myScoreMVC.myScoreTxt.text = buffer + rawScore;
			}
		}
		
		
		
		// ---------------- SAMPLE & GUESS BUTTONS ----------------------
		
		// temporarily disables the buttons
		private function deactivateButtons():void
		{
			dataBtn.mouseEnabled = false;
			guessBtn.mouseEnabled = false;
			
			// safety net that prevents buttons from not disappearing properly.;
			dataBtn.removeEventListener( Event.ENTER_FRAME, appearInner);
			sampleTxt.removeEventListener( Event.ENTER_FRAME, appearInner);
			guessBtn.removeEventListener( Event.ENTER_FRAME, appearInner);

			dataBtn.alpha = 0.1;
			sampleTxt.alpha = 0.1;
			guessBtn.alpha = 0.1;
		}

		// reactivates the disabled buttons.
		private function reactivateButtons(triggerEvent:Event):void
		{
			dataBtn.mouseEnabled = true;
			dataBtn.enabled = true;
			dataBtn.gotoAndStop(1);
			guessBtn.mouseEnabled = true;

			appear( sampleTxt);
			appear( dataBtn);
			appear( guessBtn);
		}
		
		// function that's called when you want to sample more data
		private function clickSampleButton( triggerEvent:Event):void
		{
			dispatchEvent( new InferenceEvent( InferenceEvent.SAMPLE));
		}
		
		
		// function that's called when you click the [Guess] button
		private function clickGuessButton( triggerEvent:MouseEvent):void
		{
			switchToGuessMode();
			doCursor(triggerEvent);// snap the cursor to the current position.
			deactivateButtons();
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
		
		private function disappearInner(triggerEvent:Event):void
		{
			triggerEvent.target.alpha -=  0.1;
			if (triggerEvent.target.alpha <= -0)
			{
				triggerEvent.target.removeEventListener( triggerEvent.type, disappearInner);
			}
		}



		// ---------- PRIVATE SETTERS FOR IQR AND INTERVAL ------------------
		
		// sets the length of the IQR
		private function setIQR( arg:Number):void
		{
			_IQR = arg;

			var myTween:Tween = new Tween(iqrLineMVC,"width",Elastic.easeOut,iqrLineMVC.width,(numlineToStage(arg) - startPoint),20);
			//iqrLineMVC.width = numlineToStage(arg) - startPoint;

			iqrTxt.text = arg.toString();
			distributionMVC.width = (numlineToStage(arg) - startPoint) * 3.472;
		}

		// sets the length of the Interval
		private function setInterval( arg:Number):void
		{
			_interval = arg;

			var myTween:Tween = new Tween(intervalLineMVC,"width",Elastic.easeOut,intervalLineMVC.width,(numlineToStage(arg) - startPoint) * 2,20);
			//intervalLineMVC.width = numlineToStage(arg) - startPoint;
			guessCursorMVC.cursor.width = (numlineToStage(arg) - startPoint) * 2;
			intervalTxt.text = arg.toString();
		}
		
		
		
		// ---------------- GUESSING FUNCTIONS ---------------------
		
		// places a guess based on the cursor's position. The distribution "wipes" on screen, then shows if it was correct or not.
		private function makeGuess(triggerEvent:Event):void
		{

			Mouse.show();
			_guess = Number(guessCursorMVC.pos.text); 

			// show the underlying distribution
			distributionMVC.gotoAndStop("neutral");
			distributionMVC.alpha = 1;
			if (_median < 50)
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
		private function forceFailGuess(triggerEvent:Event):void{
			Mouse.show();
			_guess = -100;
			distributionMVC.alpha = 1;
			distributionMVC.gotoAndStop("neutral");
			
			distributionMVC.curveMVC.gotoAndStop("on");
			revealAnswer(triggerEvent, false);
			var failTween:Tween = new Tween( distributionMVC, "scaleY", Elastic.easeOut, 0, distributionScaleY, 20);
		}

		// hides the distribution, and returns to mouse mode
		private function clearGraph( triggerEvent:MouseEvent):void
		{
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, clearGraph);
			switchToMouseMode();
			reactivateButtons( triggerEvent);
			appear(iqrLineMVC);//iqrLineMVC.addEventListener(Event.ENTER_FRAME, appear);
		}

		// turns the distribution red (lose) or green (lose), based on the guess
		function revealAnswer( triggerEvent:Event, playAnimation:Boolean = true):void
		{
			if ( Math.abs( _guess - _median) <= _interval)
			{
				distributionMVC.gotoAndPlay(	playAnimation ? "win" : "won");
				earnScore(100);
				dispatchEvent( new InferenceEvent( InferenceEvent.CORRECT_GUESS));
			}
			else
			{
				distributionMVC.gotoAndPlay(	playAnimation ? "lose" : "lost");
				loseLife();
				dispatchEvent( new InferenceEvent( InferenceEvent.INCORRECT_GUESS));
			}
						
			stage.addEventListener(MouseEvent.MOUSE_DOWN, finishRound);
		}



		// ------------- MISC ----------------------
		
		// handles the movement of the guess cursor.
		private function doCursor( triggerEvent:MouseEvent):void
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
		
		// goes on to a new round
		private function finishRound( triggerEvent:MouseEvent):void
		{
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, finishRound);

			disappear( distributionMVC);
			disappear( guessCursorMVC);
			
			switchToMouseMode();

			newRoundTimer.reset();
			newRoundTimer.start();
		}
		
		private function handleKeys( triggerEvent:KeyboardEvent):void{
			if(triggerEvent.keyCode == 27){ 	// escape
				switchToMouseMode();
				reactivateButtons(triggerEvent);
			}
		}
		
		
		
		
		// ------------------------------------------------
		// PROXY SECTION!! REMOVE ALL THIS BEFORE PUBLISH
		
		//How do we really want to start new rounds?
		private function startNewRound( triggerEvent:TimerEvent = null):void
		{
			newRound( Math.random() * 10 + 7, Math.random() * 10 + 1, Math.random() * 100, Math.random() * 10 + 1);
			reactivateButtons(triggerEvent);
		}
	
		private function doTheSamples( triggerEvent:InferenceEvent):void{
			sampleData(triggerEvent);
		}
	}
}