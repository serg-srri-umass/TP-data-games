package embedded_asset_classes
{

	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;

	public class SpaceRace extends spaceRaceSWC
	{
		
		// debug
		private var standAloneDebug:Boolean = true; // Turn FALSE, when integrated into the game.

		// -----------------
		// --- VARIABLES ---
		// -----------------

		// player variables:
		private var _playerNameGreen:String; 
		private var _playerNameRed:String; 
		
		// round & guessing variables:
		private var _median:Number;			// the _median of the distribution that is currently being sampled.
		private var _guess:Number = -100; 	// The guess #. Valid guesses range from 0 - 100. 
		private var _interval:int; 			// GUESS INTERVAL
		private var _IQR:int; 				// DISTRIBUTION IQR
		private var _sampleSize:int;		// how many samples are drawn each time the sample button is clicked.

		// timers:
		public var newRoundTimer:Timer = new Timer(500, 1); // one second delay between old round finishing & new round being requested.

		// scoring variables:
		public const WINNING_SCORE:int = 6;
		private var _greenScore:int = 0;
		private var _redScore:int = 0;
		
	
		// ----------------------
		// --- PUBLIC METHODS ---
		// ----------------------

		// constructor
		public function SpaceRace( stage:Stage, levelsFunc:Function, aboutFunc:Function, videoFunc:Function)
		{
			topBarMVC.setStage( stage);
			topBarMVC.backFunction = levelsFunc;
			topBarMVC.aboutFunction = aboutFunc;
			topBarMVC.videoFunction = videoFunc;
			
			bodyMVC.setStage( stage);
			bodyMVC.setSpaceRace( this);
			
			// event listener section:
			this.addEventListener( Event.ENTER_FRAME, handleEnterFrame);
			newRoundTimer.addEventListener(TimerEvent.TIMER, requestNewRound);	// when the new round timer completes, the new round starts.;
		}

		
		
		// ----------- NEW ROUND / NEW GAME --------------
		
		// start a new round. Give it an IQR, interval, the distribution median, & sample size.
		public function newRound( iqr:int, interval:int, median:Number, sampleSize:int):void
		{
			this.median = median;
			this.sampleSize = sampleSize;
			this.setIQR(iqr);
			this.setInterval(interval);
			
			trace("The median is: " + median);
			bodyMVC.moveDistributionTo(_median);
			bodyMVC.distributionMVC.alpha = 0;
			bodyMVC.controlsMVC.hideGreen();
			bodyMVC.controlsMVC.hideRed();
			bodyMVC.startDataSampling();
		}
		
		// start a new game.
		public function newGame( possibleIQRs:Array, startingIQR:Number, possibleIntervals:Array, startingInterval:Number, levelNumber:int):void{
			resetScore();
			bodyMVC.setPossibleIQRs(possibleIQRs[0], possibleIQRs[1], possibleIQRs[2], possibleIQRs[3]);
			bodyMVC.setPossibleIntervals(possibleIntervals[0], possibleIntervals[1], possibleIntervals[2], possibleIntervals[3]);
			bodyMVC.showFeedback("Level " + levelNumber, "Start Game");
			bodyMVC.promptTxt.text = "";
			//requestNewRound();
		}
		
		// ----------- GETTERS & SETTERS -------------
		
		public function get playerNameGreen():String{	return _playerNameGreen;	}
		public function get playerNameRed():String{		return _playerNameRed;	}
		
		public function get iqr():int{			return _IQR;		}
		public function get interval():int{		return _interval;	}
		public function get median():Number{	return _median;		}
		public function get guess():Number{		return _guess;		}
		public function get sampleSize():int{	return _sampleSize;	}

		public function set playerNameGreen( arg:String):void{
			_playerNameGreen = arg;
		}
		
		public function set playerNameRed( arg:String):void{
			_playerNameRed = arg;
		}
		
		public function set sampleSize( arg:int):void{
			_sampleSize = arg;
			bodyMVC.setSampleSizeText( arg);
		}
		
		// WARNING: THIS DOES NOT MAKE A GUESS. IT MERELY RESETS THE POSITION OF THE LAST PLACED GUESS.
		public function set guess( arg:Number):void{
			_guess = arg;
		}
		
		// sets the length of the IQR
		public function setIQR( arg:int):void
		{
			_IQR = arg;
			bodyMVC.setActiveIQR(arg);
		}

		// sets the length of the Interval
		public function setInterval( arg:int, hidden:Boolean = false):void
		{
			_interval = arg;
			bodyMVC.setActiveInterval(arg);
		}
		
		public function set median( arg:Number):void{
			_median = arg;
		}
		
		
		// ---------- DATA SAMPLING ------------- 
		
		// samples data of the chosen sample size.
		public function sampleData( triggerEvent:Event = null):Vector.<Number>{
			return bodyMVC.sampleData( triggerEvent);
			return null;
		}
		
		// call this method when the player attempts to draw too much data
		//public function overdraw( triggerEvent:Event = null):void{
//			mainMVC.overdraw( triggerEvent);
		//}
		
		// return time between single data samples in milliseconds
		public function getDataSpeed():uint {
			return (1000 / 24) * bodyMVC.dataPopSpeed; // (1000ms / 24 frames) * frames per sample
		}
		
		
		// ----------- GUESSING ----------------
		public function prepareGuessRed( triggerEvent:Event = null):void{
			bodyMVC.controlsMVC.openInputCancelRed();
			bodyMVC.promptTxt.text = "Place your guess on the numberline, or type it in.";
			
			// auto-set the focus of the textbox
			// taken from http://reality-sucks.blogspot.com/2007/11/actionscript-3-adventures-setting-focus.html
			var targetTxt:TextField = bodyMVC.controlsMVC.controlsRedMVC.inputMVC.inputTxt;
			InferenceGames.stage.focus = targetTxt;
			targetTxt.text = " ";
			targetTxt.setSelection( targetTxt.length, targetTxt.length);
			targetTxt.text = "";			
		}
		
		public function prepareGuessGreen( triggerEvent:Event = null):void{
			bodyMVC.controlsMVC.openInputCancelGreen();
			bodyMVC.promptTxt.text = "";
			bodyMVC.controlsMVC.dispatchEvent( new InferenceEvent( InferenceEvent.EXPERT_START_TYPING));
			
			var targetTxt:TextField = bodyMVC.controlsMVC.controlsGreenMVC.inputMVC.inputTxt;
			InferenceGames.stage.focus = targetTxt;
			targetTxt.text = " ";
			targetTxt.setSelection( targetTxt.length, targetTxt.length);
			targetTxt.text = "";	
		}
		
		// ----------- SCORING ------------------
		
		public function get greenScore():int{		return _greenScore;	}
		public function get redScore():int{			return _redScore;	}
		
		public function set greenScore(arg:int):void { 	_greenScore = arg; 	}
		public function set redScore(arg:int):void {	_redScore = arg;	}
		
		// lose a point of "life", when you guess incorrectly, or overdraw.
		public function earnPointRed( triggerEvent:Event = null):void{
			redScore++;
			topBarMVC.earnPoint( true);
		}
		
		
		public function get activePlayerIsRed():Boolean{
			return bodyMVC.controlsMVC.activePlayerIsRed;
		}
		
		// earn X points. This is pretty useless at the moment, because the score system shouldn't work like this.
		public function earnPointGreen( triggerEvent:Event = null):void{
			greenScore++;
			topBarMVC.earnPoint( false);
		}
		
		// reset the score to its starting value.
		public function resetScore():void{
			greenScore = 0;
			redScore = 0;
			topBarMVC.resetScore();
		}
		
		// -----------------------
		// --- PRIVATE METHODS ---
		// -----------------------
		
		// ---------------- ON ENTER FRAME --------------
		// the methods in this section are called every frame (@24 fps)
		
		private function handleEnterFrame(triggerEvent:Event):void
		{
			bodyMVC.handleEnterFrame( triggerEvent);
		}
		
		// ---------------- SAMPLE & GUESS BUTTONS ----------------------

		// ------ REQUEST NEW ROUND --------------
		private function requestNewRound( triggerEvent:Event = null):void{
			dispatchEvent( new InferenceEvent( InferenceEvent.REQUEST_NEW_ROUND));
		}
	}
}