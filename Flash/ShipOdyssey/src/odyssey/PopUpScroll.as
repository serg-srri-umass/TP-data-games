package odyssey
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import common.TextFormatter;
	import odyssey.missions.Missions;
	
	public class PopUpScroll extends popUps
	{
		private var game:ShipMissionAPI;	//reference to the main. Allows this class to directly interact with the application.
		
		private static const kLevelInstructionsArray:Array = new Array(Missions.mission1.instructions, Missions.mission2.instructions, Missions.mission3.instructions, Missions.mission4.instructions);
		private static const kLevelTitleArray:Array = new Array(Missions.mission1.title, Missions.mission2.title, Missions.mission3.title, Missions.mission4.title);
		
		private var selectedLevel:int = 1;
		private var delayTimer:Timer = new Timer(1500, 0); //used to animate 'fade out'. The dely before the screen disappears.
		private var okayFunc:Function = emptyFunction;	// the funciton that's assigned to the okay button
		
		private function emptyFunction():void{	trace("EMPTY FUNCTION");	}
		
		public function PopUpScroll(api:* = null) {
			game = api;
		}
		
		public function showLoading():void{
			visible = true;
			gotoAndStop("load");
		}
		
		public function loseGame(e:Event = null):void {
			visible = true;
			gotoAndStop("lose");
			mainBtn.addEventListener(MouseEvent.CLICK, replayLevelButtonHandler);
			chooseLevelBtn.addEventListener(MouseEvent.CLICK, chooseLevelButtonHandler);
		}
		
		public function winGame(e:Event = null):void {
			visible = true;
			gotoAndStop("win");
			mainBtn.addEventListener(MouseEvent.CLICK, chooseLevelButtonHandlerNext);
		}
		
		// click the 'choose level' button
		private function chooseLevelButtonHandler(e:MouseEvent):void{
			game.restartMission(false);
			chooseLevelBtn.removeEventListener(MouseEvent.CLICK, chooseLevelButtonHandler);
			chooseHuntLevel();
		}
		
		
		// the 'continue' button, for when you've won the game.
		private function chooseLevelButtonHandlerNext(e:MouseEvent):void{
			mainBtn.removeEventListener(MouseEvent.CLICK, chooseLevelButtonHandlerNext);
			if(selectedLevel < 4)
				selectedLevel++;
			chooseHuntLevel(true, false);
		}
		
		// click the 'retry' button
		private function replayLevelButtonHandler(e:MouseEvent):void{
			mainBtn.removeEventListener(MouseEvent.CLICK, replayLevelButtonHandler);
			var mHuntLevel:int = game.getHuntMission();
			game.startHunt(mHuntLevel + 1);
			game.restartMission();
		}
		
		// select what level will be played.
		public function chooseHuntLevel(sailToNext:Boolean = false, skipAnimation:Boolean = true):void 
		{
			game.setGameTitle("Choose a Mission");
			
			visible = true;
			gotoAndStop("level");
			displayMissionInstructions(null, skipAnimation);
			
			missions.mission1.addEventListener(MouseEvent.MOUSE_DOWN, displayMission1);
			missions.mission2.addEventListener(MouseEvent.MOUSE_DOWN, displayMission2);
			missions.mission3.addEventListener(MouseEvent.MOUSE_DOWN, displayMission3);
			missions.mission4.addEventListener(MouseEvent.MOUSE_DOWN, displayMission4);
			playBtn.addEventListener(MouseEvent.CLICK, startGame);
		}
		
		private function startGame(e:MouseEvent, autoStart:Boolean = true):void {
			game.startHunt(selectedLevel, e, autoStart);
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
		
		//remove all listeners from the level chooser window & close it.
		public function stripMissionButtonListeners():void {
			visible = false;
			missions.mission1.removeEventListener(MouseEvent.MOUSE_DOWN, displayMission1);
			missions.mission2.removeEventListener(MouseEvent.MOUSE_DOWN, displayMission2);
			missions.mission3.removeEventListener(MouseEvent.MOUSE_DOWN, displayMission3);
			missions.mission4.removeEventListener(MouseEvent.MOUSE_DOWN, displayMission4);
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
		}
		public function isShowingHelp():Boolean{
			return currentFrameLabel == "help";
		}

		
		// returns the name of the current level
		public function getCurrentLevelTitle(arg:int = -1):String
		{
			var switcher:int = (arg > 0 ? arg : selectedLevel);
			return kLevelTitleArray[switcher - 1];
		}
		
		//returns the current level description
		public function getCurrentLevelDescription(arg:int = -1):String
		{
			var switcher:int = (arg > 0 ? arg : selectedLevel);
			return kLevelInstructionsArray[switcher - 1];
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
	}
}
