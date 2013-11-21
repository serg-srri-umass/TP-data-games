package 
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;

	public class GameScreen extends MovieClip
	{

		// -----------------
		// --- VARIABLES ---
		// -----------------

		// round & guessing variables:
		private var _median:Number;			// the _median of the distribution that is currently being sampled.
		private var _guess:Number = -100; 	// The guess #. Ranges from 0 - 100. 
		private var _interval; 				// GUESS INTERVAL
		private var _IQR:int; 				// GUESS IQR
		private var _sampleSize:int;		// how many samples are drawn each time the sample button is clicked.

		// timers:
		public var newRoundTimer:Timer = new Timer(500, 1); // one second delay between new round

		// scoring variables:
		public const STARTING_LIFE:int = 6, WINNING_SCORE:int = 6;
		private var _life:int = STARTING_LIFE;
		private var _score:int = 0;

		// ----------------------
		// --- PUBLIC METHODS ---
		// ----------------------

		// constructor
		public function GameScreen()
		{
			// event listener section:
			this.addEventListener( Event.ENTER_FRAME, handleEnterFrame);
			mainMVC.dataBtn.addEventListener(MouseEvent.CLICK, clickSampleButton);	// click the sample more data button;
			mainMVC.guessBtn.addEventListener(MouseEvent.CLICK, clickGuessButton);		// click the guess button;
			newRoundTimer.addEventListener(TimerEvent.TIMER, requestNewRound);	// when the new round timer completes, the new round starts.;
			mainMVC.switchToMouseMode();
		}
		
		
		// ----------- NEW ROUND / NEW GAME --------------
		
		// start a new round. Give it an IQR, interval, and the distribution median.
		public function newRound( iqr:int, interval:int, median:Number, sampleSize:int):void
		{
			mainMVC.switchToMouseMode(); // ensure the round starts in mouse-mode
			mainMVC.reactivateButtons();
			this.median = median;
			this.sampleSize = sampleSize;
			this.iqr = iqr;
			this.interval = interval;
			
			trace("The median is: " + median);
			mainMVC.moveDistributionTo(_median); //distributionMVC.x = numlineToStage(_median);
		}
		
		// start a new game.
		public function newGame( triggerEvent:Event = null):void{
			mainMVC.switchToMouseMode(); // ensure the game starts in mouse-mode
			mainMVC.reactivateButtons( triggerEvent);
			resetScore();
			resetLife();
			requestNewRound( triggerEvent);
		}
		
		// ----------- GETTERS & SETTERS -------------
		
		public function get iqr():int{			return _IQR;		}
		public function get interval():int{		return _interval;	}
		public function get median():Number{	return _median;		}
		public function get guess():Number{		return _guess;		}
		public function get sampleSize():int{	return _sampleSize;	}

		public function set sampleSize( arg:int):void{
			_sampleSize = arg;
			mainMVC.setSampleSize( arg);
		}
		
		// WARNING: THIS DOES NOT MAKE A GUESS. IT MERELY RESETS THE POSITION OF THE LAST PLACED GUESS.
		public function set guess( arg:Number):void{
			_guess = arg;
		}
		
		// sets the length of the IQR
		public function set iqr( arg:int):void
		{
			_IQR = arg;
			mainMVC.setIQR( arg, false);
		}

		// sets the length of the Interval
		public function set interval( arg:int):void
		{
			_interval = arg;
			mainMVC.setInterval( arg, false);
		}
		
		public function set median( arg:Number):void{
			_median = arg;
		}
		
		
		// ---------- DATA SAMPLING ------------- 
		
		// samples data of the chosen sample size.
		public function sampleData( triggerEvent:Event = null):Vector.<Number>{
			dispatchEvent( new Event( InferenceEvent.SAMPLE));
			return mainMVC.sampleData( triggerEvent);
		}
		
		// call this method when the player attempts to draw too much data
		public function overdraw( triggerEvent:Event = null):void{
			mainMVC.overdraw( triggerEvent);
			dispatchEvent( new InferenceEvent( InferenceEvent.OVERDRAW));
		}
		
		// ----------- SCORING ------------------
		
		public function get life():int{		return _life;	}
		public function get score():int{	return _score;	}
		
		// lose a point of "life", when you guess incorrectly, or overdraw.
		public function loseLife( triggerEvent:Event = null):void{
			_life--;
			topBarMVC.loseLife(_life);			
		}
		
		// earn X points. This is pretty useless at the moment, because the score system shouldn't work like this.
		public function earnPoint():void{
			_score++;
			topBarMVC.earnPoint();
		}
		
		// reset the score to its starting value.
		public function resetScore():void{
			_score = 0;
			topBarMVC.resetScore();
		}
		
		// reset the life to its starting value
		public function resetLife():void{
			_life = STARTING_LIFE;
			topBarMVC.resetLife( STARTING_LIFE);
		}
		

		// -----------------------
		// --- PRIVATE METHODS ---
		// -----------------------
		
		
		// ---------------- ON ENTER FRAME --------------
		// the methods in this section are called every frame (@24 fps)
		
		private function handleEnterFrame(triggerEvent:Event):void
		{
			mainMVC.handlePops();
		}
		

		// ---------------- SAMPLE & GUESS BUTTONS ----------------------
		
		// function that's called when you want to sample more data
		private function clickSampleButton( triggerEvent:Event):void
		{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_SAMPLE));
		}
		
		
		// function that's called when you click the [Guess] button
		private function clickGuessButton( triggerEvent:MouseEvent):void
		{
			mainMVC.switchToGuessMode();
			mainMVC.doCursor(triggerEvent);// snap the cursor to the current position.
			mainMVC.deactivateButtons( true);
		}

		// ------ REQUEST NEW ROUND --------------
		
		private function requestNewRound( triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_NEW_ROUND));
		}
		
		
		// PROXY SECTION!! REMOVE ALL THIS BEFORE PUBLISH
		//How do we really want to start new rounds?
		private function startNewRound( triggerEvent:InferenceEvent = null):void
		{
			newRound( Math.random() * 10 + 7, Math.random() * 10 + 1, Math.random() * 100, Math.random() * 10 + 1);
		}
	
		private function doTheSamples( triggerEvent:InferenceEvent):void{
			trace(sampleData(triggerEvent));
		}
	}
}