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
		

		// -----------------
		// --- VARIABLES ---
		// -----------------

		// player variables:
		public const PLAYER_PHRASE:String = "Your turn";
		public const EXPERT_PHRASE:String = "Expert's turn";
		
		private var _expertTurnString:String; // the string it says when it's the expert's turn.
		private var _playerTurnString:String; // the string it says when its the player's turn.
		
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
		private var _expertScore:int = 0;
		private var _humanScore:int = 0;
		
	
		// ----------------------
		// --- PUBLIC METHODS ---
		// ----------------------

		// constructor
		public function SpaceRace( stage:Stage, aboutFunc:Function, videoFunc:Function)
		{
			topBarMVC.setStage( stage);
			topBarMVC.aboutFunction = aboutFunc;
			topBarMVC.videoFunction = videoFunc;
			
			bodyMVC.setStage( stage);
			bodyMVC.setSpaceRace( this);
			
			// event listener section:
			this.addEventListener( Event.ENTER_FRAME, handleEnterFrame);
			newRoundTimer.addEventListener(TimerEvent.TIMER, requestNewRound);	// when the new round timer completes, the new round starts.;
			showMainMenu( 1, 0 );
		}
		
		public function establishLevels( ...rest):void{	// this method takes in any number of Arrays. The arrays should have 4 properties:
														// Name:String, IQR:int, Interval:int, clickFunction:Function
			for( var i:int = 0; i < rest.length; i++){
				var myLevel:Array = rest[i];
				SpaceRaceControls.INSTANCE.setLevelButton(i + 1, myLevel[0], myLevel[1], myLevel[2], myLevel[3]);
			}
		}

		// ----------- NEW ROUND / NEW GAME / END GAME --------------
		
		// start a new round. Give it an IQR, interval, the distribution median, & sample size.
		public function newRound( iqr:int, interval:int, median:Number, sampleSize:int):void
		{
			this.median = median;
			this.sampleSize = sampleSize;
			this.setIQR(iqr);
			this.setInterval(interval);
			
			trace("The median is: " + median);
			bodyMVC.moveDistributionTo(_median);
			bodyMVC.hideAnswer();
			bodyMVC.controlsMVC.hideExpert();
			bodyMVC.controlsMVC.hideHuman();
			bodyMVC.startDataSampling();
		}
		
		// start a new game.
		public function newGame( possibleIQRs:Array, startingIQR:Number, possibleIntervals:Array, startingInterval:Number, levelNumber:int):void{
			//resetScore();
			
			bodyMVC.setPossibleIQRs(possibleIQRs[0], possibleIQRs[1], possibleIQRs[2], possibleIQRs[3], possibleIQRs[4]);
			bodyMVC.setPossibleIntervals(possibleIntervals[0], possibleIntervals[1], possibleIntervals[2], possibleIntervals[3], possibleIntervals[4]);
			//bodyMVC.showFeedback("Level " + levelNumber, "Start Game");
			//bodyMVC.promptTxt.text = "";
						
			bodyMVC.controlsMVC.hideHuman();		// Don't start with either player's controls showing.
			bodyMVC.controlsMVC.hideExpert();
			
		}
		
		// ends the current game & shows  the main menu
		public function endGame( newLevelUnlocked:Boolean = false):void{
			bodyMVC.controlsMVC.disableAndHideEndGameBtn();
			
			bodyMVC.controlsMVC.hideHuman();
			bodyMVC.controlsMVC.hideExpert();
			bodyMVC.controlsMVC.hideFeedback();
			bodyMVC.promptTxt.text = "";
			bodyMVC.hideAnswer();; // hide the distribution if it was being shown.
			
			resetScore();
			topBarMVC.setTrim("white");
			
			//bodyMVC.controlsMVC.mainMenuMVC.newLevelsTxt.text = (newLevelUnlocked ? "New level unlocked!" : "");
			
			//hide the interval and IQR bars when ending game
			bodyMVC.setPossibleIQRs();
			bodyMVC.setPossibleIntervals();
		}
		
		public function showMainMenu( unlockedLevels:int, completedLevels:int ):void{
			bodyMVC.controlsMVC.showMainMenu();
			bodyMVC.controlsMVC.hideHuman();
			bodyMVC.controlsMVC.hideExpert();
			bodyMVC.controlsMVC.hideFeedback();
			
			// unlock and check the individual levels
			for( var i:int = 1; i <= 4; i++){
				if( i <= unlockedLevels){
					bodyMVC.controlsMVC.unlockLevelButton(i);
				} else {
					bodyMVC.controlsMVC.lockLevelButton(i);
				}
				if( i <= completedLevels) {
					bodyMVC.controlsMVC.checkLevelButton(i);
				} else {
					bodyMVC.controlsMVC.uncheckLevelButton(i);
				}
			}
			
		}
		
		// ----------- GETTERS & SETTERS -------------
		
		public function get playerTurnString():String{	return _playerTurnString;	}
		public function get expertTurnString():String{	return _expertTurnString;	}
		
		public function get iqr():int{			return _IQR;		}
		public function get interval():int{		return _interval;	}
		public function get median():Number{	return _median;		}
		public function get guess():Number{		return _guess;		}
		public function get sampleSize():int{	return _sampleSize;	}
		
		// set how many samples will be drawn per chunk.
		public function set sampleSize( arg:int):void{
			_sampleSize = arg;
			_playerTurnString = PLAYER_PHRASE + ". Sampling " + arg + " at a time.";
			_expertTurnString = EXPERT_PHRASE + ". Sampling " + arg + " at a time.";
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
		public function prepareGuessHuman( triggerEvent:Event = null):void{
			bodyMVC.controlsMVC.openInputCancelHuman();
			bodyMVC.promptTxt.text = "Place your guess on the numberline, or type it in.";
			
			// auto-set the focus of the textbox
			// taken from http://reality-sucks.blogspot.com/2007/11/actionscript-3-adventures-setting-focus.html
			var targetTxt:TextField = bodyMVC.controlsMVC.controlsHumanMVC.inputMVC.inputTxt;
			InferenceGames.stage.focus = targetTxt;
			targetTxt.text = " ";
			targetTxt.setSelection( targetTxt.length, targetTxt.length);
			targetTxt.text = "";			
		}
		
		public function prepareGuessExpert( triggerEvent:Event = null):void{
			bodyMVC.controlsMVC.openInputCancelExpert();
			bodyMVC.promptTxt.text = "";
			bodyMVC.controlsMVC.dispatchEvent( new InferenceEvent( InferenceEvent.EXPERT_START_TYPING));
			
			var targetTxt:TextField = bodyMVC.controlsMVC.controlsExpertMVC.inputMVC.inputTxt;
			InferenceGames.stage.focus = targetTxt;
			targetTxt.text = " ";
			targetTxt.setSelection( targetTxt.length, targetTxt.length);
			targetTxt.text = "";	
		}
		
		// ----------- SCORING ------------------
		
		public function get expertScore():int{		return _expertScore;	}
		public function get humanScore():int{			return _humanScore;	}
		
		public function set expertScore(arg:int):void { 	_expertScore = arg; 	}
		public function set humanScore(arg:int):void {	_humanScore = arg;	}
		
		// lose a point of "life", when you guess incorrectly, or overdraw.
		public function earnPointHuman( triggerEvent:Event = null):void{
			humanScore++;
			topBarMVC.earnPoint( true);
		}
		
		
		public function get activePlayerIsHuman():Boolean{
			return bodyMVC.controlsMVC.activePlayerIsHuman;
		}
		
		// earn X points. This is pretty useless at the moment, because the score system shouldn't work like this.
		public function earnPointExpert( triggerEvent:Event = null):void{
			expertScore++;
			topBarMVC.earnPoint( false);
		}
		
		// reset the score to its starting value.
		public function resetScore():void{
			expertScore = 0;
			humanScore = 0;
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