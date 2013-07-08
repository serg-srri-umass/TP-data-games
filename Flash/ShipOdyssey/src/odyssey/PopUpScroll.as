package odyssey
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class PopUpScroll extends popUps
	{
		private var game:ShipMissionAPI;	//reference to the main. Allows this class to directly interact with the application.
		
		public static const kLevel1Instructions:String = "At this location, each treasure is worth $12,000. You start with $15,000. To complete it, earn $25,000. Rats are free, but be careful; a missed hook will cost you $5,000.";
		public static const kLevel2Instructions:String = "Each treasure is still worth $12,000, but now there are either 0, 1, or 2 treasures. Check the loot meter for your new goals.";
		public static const kLevel3Instructions:String = "Each treasure is now worth $20,000. Rats will cost you $100 each. Check the loot meter for your new goals.";
		public static const kLevel4Instructions:String = "Each treasure is worth $23,000. The water is deep here,  so the rat readings will be less accurate. Check the loot meter for your new goals.";
		public static const kLevel5Instructions:String = "";
		private static const kLevelInstructionsArray:Array = new Array(kLevel1Instructions, kLevel2Instructions, kLevel3Instructions, kLevel4Instructions, kLevel5Instructions);
		
		//NOTE: ON THE MAP, Titles are set in the .swc. If they're changed, the .swc has to be updated as well.
		public static const kLevel1Title:String = "Hundreds o' Rats";
		public static const kLevel2Title:String = "Treasure or Not";
		public static const kLevel3Title:String = "Rat Shortage";
		public static const kLevel4Title:String = "Deep Water";
		public static const kLevel5Title:String = "Choose Yer Hook";
		private static const kLevelTitleArray:Array = new Array(kLevel1Title, kLevel2Title, kLevel3Title, kLevel4Title, kLevel5Title);
		
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
			body.text = kLevel1Instructions;
			selectedLevel = 1;
			titleBar.gotoAndStop(selectedLevel);
		}
		private function displayMission2(e:MouseEvent):void {
			body.text = kLevel2Instructions;
			selectedLevel = 2;
			titleBar.gotoAndStop(selectedLevel);
		}
		private function displayMission3(e:MouseEvent):void {
			body.text = kLevel3Instructions;
			selectedLevel = 3;
			titleBar.gotoAndStop(selectedLevel);
		}
		private function displayMission4(e:MouseEvent):void {
			body.text = kLevel4Instructions;
			selectedLevel = 4;
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