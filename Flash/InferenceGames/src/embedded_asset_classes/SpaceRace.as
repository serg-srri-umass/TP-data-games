// This is the top bar, that animates data shooting into the graph.

/* STRUCTURE:
	- this
	|
	|- mainMVC (Controlled by SpaceRaceBody.as)
		|
		|- SpaceRaceBody API
			| *These methods must be called in the constructor of SpaceRace*
			|	| setSpaceRace( arg:*):void;
			|	|	|	the body needs a reference to this. Arg must == this.
			|	| setStage (arg:Stage):void;
			|	|	|	the body needs a reference to Inference Games' Stage, so it can add listeners to it.
			|
			| moveDistributionTo( arg:Number):void;
			|	moves the current distribution to the given # on the numberline.
			|
			| setSampleSize( arg:int):void;
			|	sets how many samples will be drawn.
			|
			| sampleData( triggerEvent:Event = null):Vector.<Number>;
			|	samples X data points, where X is the sample size. Returns a vector of their locations on the number line.
			|	dispatches InferenceEvent.
			|
			| overdraw( triggerEvent:Event = null):void;
			|	"Sample too big". Overdraws. Causes the loss of 1/2 heart. 
			|	dispatches InferenceEvent.
			|
			| handleEnterFrame( triggerEvent:Event):void;
			|	method that should be called every frame. Handles the "data pop" animations, as they are needed.
			|
			| deactivateButtons( triggerEvent:Event = null, canEscape:Boolean = false):void;
			|	turns off the "sample" & "guess" buttons. 
			|	If canEscape is true, pressing 'escape' will cancel this state. The guess button will say '[Esc] to cancel'
			|	
			| reactivateButtons( triggerEvent:Event = null):void;
			|	turns on the "sample" & "guess" buttons
			|
			| setIQR( arg:int):void;
			|	set the IQR length.
			|
			| setInterval( arg:int):void;
			|	set the interval length.
			|
			| moveCursorToMousePosition( triggerEvent:MouseEvent):void;
			|	moves the guess cursor to the mouse's current position.
			|
			| switchToGuessMode( triggerEvent:Event = null):void;
			|	hides the mouse; shows the guess cursor. Sets up all event listeners to guess. When the player clicks, guess will be made.
			|	dispatches InferenceEvent.
			|
			| switchToMouseMode( triggerEvent:Event = null):void;
			|	hides the guess cursor; shows the mouse. Reactivates the buttons, sets up all that's needed to be in the 'standard mode'.
			|	dispatches InferenceEvent.
			|
			| isInGuessMode():Boolean;
			|	returns true if in 'guess mode', returns false if in 'mouse mode'.
			|
			| public var dataPopSpeed:Number
			|	determines how much time occurs between the arrival of data pops.
			|
	|
	|- topBarMVC (Controlled by SpaceRaceTopBar.as)
	|	| NOTE: The top bar is visual only. It has no bearing on actual gameplay.
	|	|- SpaceRaceTopBar API
	|		|
	|		| earnPoint():void;
	|		| 	increases the score display by 1. Nothing bad happens if the score is already maxed.
	|		|
	|		| resetScore():void;
	|		|	resets the score display.	
	|		|
	|		| loseLife():void;
	|		|	decreases the life display by 1/2 a heart. Nothing bad happens if the health is already zero.
	|		|
	|		| resetLife():void;
	|		|	resets the life display.
	|		|
	|		| setTitleMessage( arg:String):void;
	|		|	sets the title message to the given string
*/

package embedded_asset_classes
{

	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class SpaceRace extends spaceRaceSWC
	{
		
		// debug
		private var standAloneDebug:Boolean = true; // Turn FALSE, when integrated into the game.

		// -----------------
		// --- VARIABLES ---
		// -----------------

		// round & guessing variables:
		private var _median:Number;			// the _median of the distribution that is currently being sampled.
		private var _guess:Number = -100; 	// The guess #. Valid guesses range from 0 - 100. 
		private var _interval:int; 			// GUESS INTERVAL
		private var _IQR:int; 				// DISTRIBUTION IQR
		private var _sampleSize:int;		// how many samples are drawn each time the sample button is clicked.

		// timers:
		public var newRoundTimer:Timer = new Timer(500, 1); // one second delay between old round finishing & new round being requested.

		// scoring variables:
		public const STARTING_LIFE:int = 6, WINNING_SCORE:int = 6;
		private var _life:int = STARTING_LIFE;
		private var _score:int = 0;
		
	
		// ----------------------
		// --- PUBLIC METHODS ---
		// ----------------------

		// constructor
		public function SpaceRace( stage:Stage)
		{
			// event listener section:
			this.addEventListener( Event.ENTER_FRAME, handleEnterFrame);
			mainMVC.dataBtn.addEventListener(MouseEvent.CLICK, clickSampleButton);	// click the sample more data button;
			mainMVC.guessBtn.addEventListener(MouseEvent.CLICK, clickGuessButton);		// click the guess button;
			newRoundTimer.addEventListener(TimerEvent.TIMER, requestNewRound);	// when the new round timer completes, the new round starts.;
			
			mainMVC.setStage(stage);
			mainMVC.setSpaceRace(this);
						
			mainMVC.switchToMouseMode();

			// DEBUG SECTION. REMOVE ALL THIS BEFORE IT GOES LIVE.
			/*if(standAloneDebug){
				//startNewRoundDebug(); 
				addEventListener( InferenceEvent.REQUEST_SAMPLE, doTheSamples);
				//addEventListener( InferenceEvent.REQUEST_NEW_ROUND, startNewRoundDebug);
				topBarMVC.backBtn.addEventListener( MouseEvent.CLICK, newGame);
			}
			*/
		}
		
		
		// ----------- NEW ROUND / NEW GAME --------------
		
		// start a new round. Give it an IQR, interval, the distribution median, & sample size.
		public function newRound( iqr:int, interval:int, median:Number, sampleSize:int, hiddenIQR:Boolean = false, hiddenInterval:Boolean = false):void
		{
			mainMVC.switchToMouseMode(); // ensure the round starts in mouse-mode
			mainMVC.reactivateButtons();
			this.median = median;
			this.sampleSize = sampleSize;
			this.setIQR(iqr, hiddenIQR);
			this.setInterval(interval, hiddenInterval);
			
			trace("The median is: " + median);
			mainMVC.moveDistributionTo(_median);
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
		public function setIQR( arg:int, hidden:Boolean = false):void
		{
			_IQR = arg;
			mainMVC.setIQR( arg, hidden);
		}

		// sets the length of the Interval
		public function setInterval( arg:int, hidden:Boolean = false):void
		{
			_interval = arg;
			mainMVC.setInterval( arg, hidden);
		}
		
		public function set median( arg:Number):void{
			_median = arg;
		}
		
		
		// ---------- DATA SAMPLING ------------- 
		
		// samples data of the chosen sample size.
		public function sampleData( triggerEvent:Event = null):Vector.<Number>{
			return mainMVC.sampleData( triggerEvent);
		}
		
		// call this method when the player attempts to draw too much data
		public function overdraw( triggerEvent:Event = null):void{
			mainMVC.overdraw( triggerEvent);
		}
		
		// return time between single data samples in milliseconds
		public function getDataSpeed():uint {
			return (1000 / 24) * mainMVC.dataPopSpeed; // (1000ms / 24 frames) * frames per sample
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
			mainMVC.handleEnterFrame( triggerEvent);
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
			mainMVC.moveCursorToMousePosition(triggerEvent);
			mainMVC.deactivateButtons( null, true);
		}

		// ------ REQUEST NEW ROUND --------------
		private function requestNewRound( triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_NEW_ROUND));
		}
		
		
		// -----------DEBUG SECTION!! -------------------
		//	REMOVE ALL THIS BEFORE PUBLISH.
		/*
		private function startNewRoundDebug( triggerEvent:InferenceEvent = null):void
		{
			newRound( Math.random() * 10 + 7, Math.random() * 10 + 1, Math.random() * 100, Math.random() * 10 + 1);
		}
	
		private function doTheSamples( triggerEvent:InferenceEvent):void{
			if(Math.random() * 20 < 1){
				overdraw();
			}else{
				trace(sampleData(triggerEvent));
			}
		}
		*/
	}
}