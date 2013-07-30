package odyssey
{
	import common.TextFormatter;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	//import flash.events.TimerEvent;
	import flash.text.TextFormat;
	//import flash.utils.Timer;
	
	import odyssey.missions.Missions;
	
	public class PopUpScroll extends popUps
	{
		private var game:ShipMissionAPI;	//reference to the main. Allows this class to directly interact with the application.
				
		private var selectedLevel:int = 1;
		//private var delayTimer:Timer; //used to animate 'fade out'. The dely before the screen disappears.
		private var okayFunc:Function = emptyFunction;	// the funciton that's assigned to the okay button
		
		private function emptyFunction():void{	trace("EMPTY FUNCTION");	}
		
		public function PopUpScroll(api:* = null) {
			game = api;
		}
		
		public function showLoading():void{
			visible = true;
			gotoAndStop("load");
		}
		
		/*public function loseGame(e:Event = null):void {
			visible = true;
			gotoAndStop("lose");
			mainBtn.addEventListener(MouseEvent.CLICK, replayLevelButtonHandler);
			chooseLevelBtn.addEventListener(MouseEvent.CLICK, chooseLevelButtonHandler);
		}
		
		public function winGame(e:Event = null):void {
			visible = true;
			gotoAndStop("win");
			mainBtn.addEventListener(MouseEvent.CLICK, chooseLevelButtonHandlerNext);
		}*/
		
		private var printedTreasures:int = 0; // how many treasures it says you have.
		private var _treasuresFound:int = 0; // how many treasures you found this mission.
		private var _rating:int = 1;	//TO-DO rename this rating.
		
		public function set rating(arg:int):void{
			if(arg < 1 || arg > 5)
				throw new Error("rating must range from 1-5");
			_rating = arg;
		}
		public function get rating():int{
			return _rating;
		}
		public function set treasuresFound(arg:int):void{
			if(arg < 0)
				throw new Error("rating must be positive");
			_treasuresFound = arg;
		}
		
		public function finishMission(e:Event = null):void{
			visible = true;
			gotoAndStop("finishMission");
			//delayTimer = new Timer(700, 1);
			mainBtn.addEventListener(MouseEvent.CLICK, chooseLevelButtonHandlerNext);
			
			var tf:TextFormat = new TextFormat();
			tf.bold = true;
			treasureDisplay.treasure.treasures.defaultTextFormat = tf;
			treasureDisplay.treasure.treasures.defaultTextFormat = tf;
			
			if(_treasuresFound > 0){
				printedTreasures = 1;
				treasureDisplay.treasure.treasures.text = 1;
			}
			
			treasureDisplay.addEventListener("tick", tickUp);
			treasureDisplay.addEventListener("complete", finishTicks);		
		}
		
		private function tickUp(e:Event):void{
			if(printedTreasures < _treasuresFound){
				printedTreasures++;
				treasureDisplay.treasure.treasures.text = printedTreasures;
				treasureDisplay.gotoAndPlay("flash");
			}
		}
		
		private function finishTicks(e:Event):void{
			treasureDisplay.removeEventListener("tick", tickUp);
			treasureDisplay.removeEventListener("complete", finishTicks);
			ratingMVC.gotoAndPlay(1);
			ratingMVC.rating.gotoAndStop(_rating);
		}
		
		// click the 'choose level' button
		/*private function chooseLevelButtonHandler(e:MouseEvent):void{
			game.restartMission(false);
			chooseLevelBtn.removeEventListener(MouseEvent.CLICK, chooseLevelButtonHandler);
			chooseHuntLevel();
		}*/
		
		
		// the 'continue' button, for when you've won the game.
		private function chooseLevelButtonHandlerNext(e:MouseEvent):void{
			mainBtn.removeEventListener(MouseEvent.CLICK, chooseLevelButtonHandlerNext);
			chooseHuntLevel(true);
		}
		
		// click the 'retry' button
		/*private function replayLevelButtonHandler(e:MouseEvent):void{
			mainBtn.removeEventListener(MouseEvent.CLICK, replayLevelButtonHandler);
			var mHuntLevel:int = game.getHuntMission();
			game.startHunt(mHuntLevel);
			game.restartMission();
		}*/
		
		// select what level will be played.
		public function chooseHuntLevel(sailToNext:Boolean = false, skipAnimation:Boolean = true):void 
		{
			game.setGameTitle("Choose a Mission");
			
			visible = true;
			gotoAndStop("level");
			displayMissionInstructions(null, skipAnimation);
			
			missions.mission1.addEventListener(MouseEvent.MOUSE_UP, displayMission1);
			missions.mission2.addEventListener(MouseEvent.MOUSE_UP, displayMission2);
			missions.mission3.addEventListener(MouseEvent.MOUSE_UP, displayMission3);
			missions.mission4.addEventListener(MouseEvent.MOUSE_UP, displayMission4);
			missions.mission5.addEventListener(MouseEvent.MOUSE_UP, displayMission5);
			playBtn.addEventListener(MouseEvent.CLICK, startGame);
		}
		
		private function startGame(e:MouseEvent):void {
			var clearPreviousData:Boolean = deleteDataBox.checked; // whether or not the 'clear all data' box is checked.
			game.startHunt(selectedLevel, e, clearPreviousData);
		}
		
		private function displayMissionInstructions(e:MouseEvent = null, skipAnimation:Boolean = true):void {
			body.text = getCurrentLevelDescription(selectedLevel);
			titleBar.gotoAndStop(selectedLevel);
			missions.choose(selectedLevel, skipAnimation);
		}
		
		private function displayMission1(e:MouseEvent):void {
			body.text = Missions.mission1.instructions;
			selectedLevel = Missions.mission1.number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		private function displayMission2(e:MouseEvent):void {
			body.text = Missions.mission2.instructions;
			selectedLevel = Missions.mission2.number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		private function displayMission3(e:MouseEvent):void {
			body.text = Missions.mission3.instructions;
			selectedLevel = Missions.mission3.number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		private function displayMission4(e:MouseEvent):void {
			body.text = Missions.mission4.instructions;
			selectedLevel = Missions.mission4.number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		private function displayMission5(e:MouseEvent):void {
			body.text = Missions.mission5.instructions;
			selectedLevel = Missions.mission5.number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		//remove all listeners from the level chooser window & close it.
		public function stripMissionButtonListeners():void {
			visible = false;
			missions.mission1.removeEventListener(MouseEvent.MOUSE_UP, displayMission1);
			missions.mission2.removeEventListener(MouseEvent.MOUSE_UP, displayMission2);
			missions.mission3.removeEventListener(MouseEvent.MOUSE_UP, displayMission3);
			missions.mission4.removeEventListener(MouseEvent.MOUSE_UP, displayMission4);
			missions.mission5.removeEventListener(MouseEvent.MOUSE_UP, displayMission5);
			playBtn.removeEventListener(MouseEvent.CLICK, startGame);
		}
		
		// display the prompt that comes up when you find a treasure
		public function displayTreasure(text:String, func:Function, mini:Boolean = false, okay:Boolean = false):void { 
			visible = true;
			okayFunc = func;
			
			if(mini){
				gotoAndStop("treasureMini");
				nextSiteBtn.addEventListener(MouseEvent.CLICK, useOkayFunc);
			}else{
				gotoAndStop("recap");
				okayBtn.visible = okay;
				nextSiteBtn.addEventListener(MouseEvent.CLICK, useOkayFunc);
				okayBtn.addEventListener(MouseEvent.CLICK, useOkayFunc);
				doReplayPrivate();
			}
			body.text = text;
		}
		
		// display the prompt that comes up when you pull anchor
		public function displayRecap(arg:String, func:Function, okay:Boolean = false):void {
			visible = true;
			gotoAndStop("recap");
			okayFunc = func;
			body.text = arg;
			okayBtn.visible = okay;
			nextSiteBtn.addEventListener(MouseEvent.CLICK, useOkayFunc);
			okayBtn.addEventListener(MouseEvent.CLICK, useOkayFunc);
			doReplayPrivate();
		}
		
		private function useOkayFunc(e:Event):void{
			okayFunc(e);
		}
		
		// display the help
		public function displayHelp():void {
			visible = true;
			gotoAndStop("help");
			title.text = getCurrentLevelTitle();
			body.text = getCurrentLevelDescription();
			okayBtn.addEventListener(MouseEvent.CLICK, hide);
		}
		
		public function hideHelp():void{
			if(isShowingHelp())
				hide();
		}
		
		public function isShowingHelp():Boolean{
			return (visible && currentFrameLabel == "help");
		}
		
		// returns the name of the current level
		public function getCurrentLevelTitle(arg:int = -1):String
		{
			var switcher:int = (arg > 0 ? arg : selectedLevel);
			return Missions.getMission(switcher).title;
		}
		
		//returns the current level description
		public function getCurrentLevelDescription(arg:int = -1):String
		{
			var switcher:int = (arg > 0 ? arg : selectedLevel);
			return Missions.getMission(switcher).instructions;
		}
		
		public function hide(e:Event = null):void{
			visible = false;
		}
		
		private var replayArray:Array = new Array();
		private var treasuresArray:Array = new Array();
		
		public function doReplay(arg:Array, treasuresArg:Array):void{
			replayArray = arg;
			treasuresArray = treasuresArg;
		}
		
		private function doReplayPrivate():void{
			replayWindow.foreground.reset();
			var t1:Number = -1;
			var t2:Number = -1;
			
			if(treasuresArray.length == 1){
				t1 = treasuresArray[0];
			} else if(treasuresArray.length == 2) {
				t1 = treasuresArray[0];
				t2 = treasuresArray[1];
			}
			
			replayWindow.foreground.placeTreasure(t1, t2);
			if(replayArray.length > 0){
				while(replayArray.length > 0){
					var h:Array = replayArray.shift();
					replayWindow.foreground.addHook(h[0], h[1], h[2]);
				}
				replayWindow.foreground.startReplay();
			}
		}
		
		// this function brings up the confirm dialog. If you click 'okay', it will perform arg. If you cancel, nothing will happen. 
		public function confirmAction(arg:Function):void{
			visible = true;
			okayFunc = arg;
			gotoAndStop("confirm");
			mainBtn.addEventListener(MouseEvent.CLICK, useOkayFunc);
			noBtn.addEventListener(MouseEvent.CLICK, cancelAction);
		}
		
		private function cancelAction(e:Event):void{
			visible = false;
		}
		
	}
}
