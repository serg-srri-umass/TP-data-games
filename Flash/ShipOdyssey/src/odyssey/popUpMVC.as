package odyssey
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	//this class was renamed with proper capitalization.
	public class PopUpMVC extends popUps
	{
		private var game:ShipMissionAPI;	//reference to the main. Allows this class to directly interact with the application.
		
		public static const kBlankLevelDescription:String = "Mouse over a mission to view its description.";
		public static const kLevel1Instructions:String = "At this location, each treasure is worth $7,000. You start with $15,000. To complete it, earn $25,000. Rats are free, but be careful; a missed hook will cost you $5,000!";
		public static const kLevel2Instructions:String = "Each treasure is still worth $7,000, but now there are either 0, 1, or 2 treasures. Check the loot meter for your new goals!";
		public static const kLevel3Instructions:String = "Each treasure is now worth $15,000. Rats will cost you $100 each. Check the loot meter for your new goals!";
		public static const kLevel4Instructions:String = "Each treasure is worth $18,000. The water is deep here,  so the rat readings will be less accurate. Check the loot meter for your new goals!";
		
		public static const kLevel1Title:String = "Hundreds o' Rats";
		public static const kLevel2Title:String = "Uncertain Treasure";
		public static const kLevel3Title:String = "Rat Shortage";
		public static const kLevel4Title:String = "Deep Water";
		
		private var selectedLevel:String = "LEVEL 1";
		private var delayTimer:Timer = new Timer(1500, 0); //used to animate 'fade out'. The dely before the screen disappears.

		public function PopUpMVC(api:ShipMissionAPI) {
			game = api;
		}
		
		public function loseGame(e:Event):void {
			visible = true;
			gotoAndStop("lose");
			mainBtn.addEventListener(MouseEvent.CLICK, replayLevelButtonHandler);
			chooseLevelBtn.addEventListener(MouseEvent.CLICK, chooseLevelButtonHandler);
		}
		
		public function winGame(e:Event):void {
			visible = true;
			gotoAndStop("win");
			mainBtn.addEventListener(MouseEvent.CLICK, chooseLevelButtonHandlerNext);
		}
		
		// click the 'choose level' button
		private function chooseLevelButtonHandler(e:MouseEvent):void{
			chooseLevelBtn.removeEventListener(MouseEvent.CLICK, chooseLevelButtonHandler);
			chooseHuntLevel();
		}
		
		// the 'continue' button, for when you've won the game.
		private function chooseLevelButtonHandlerNext(e:MouseEvent):void{
			mainBtn.removeEventListener(MouseEvent.CLICK, chooseLevelButtonHandlerNext);
			chooseHuntLevel(true);
		}
		
		/*// handlers for end-game case interactions 
		// click the 'continue' button (when you win a mission)
		public function nextLevelButtonHandler(e:MouseEvent):void{
		popUpScreen.mainBtn.removeEventListener(MouseEvent.CLICK, nextLevelButtonHandler);
		
		mNextHuntLevel = mHuntLevel + 1;
		if(mNextHuntLevel == 1)
		secondHuntLevel();			
		else if(mNextHuntLevel == 2)
		thirdHuntLevel();				
		else if(mNextHuntLevel == 3)
		fourthHuntLevel();								
		initializeTreasureHunt();
		showCurrentLevelInstructions();
		}*/
		
		// click the 'retry' button
		private function replayLevelButtonHandler(e:MouseEvent):void{
			mainBtn.removeEventListener(MouseEvent.CLICK, replayLevelButtonHandler);
			
			var mHuntLevel:int = game.getHuntMission();
			game.startHunt(mHuntLevel + 1);
			game.restartMission();
		}
		
		// select what level will be played.
		public function chooseHuntLevel(sailToNext:Boolean = false):void 
		{
			//game.boundLevelText = "";	// clear the text at the top of the game.
			visible = true;
			gotoAndStop("level");
			displayMissionInstructions();
			
			missions.mission1.addEventListener(MouseEvent.MOUSE_DOWN, displayMission1);
			missions.mission2.addEventListener(MouseEvent.MOUSE_DOWN, displayMission2);
			missions.mission3.addEventListener(MouseEvent.MOUSE_DOWN, displayMission3);
			missions.mission4.addEventListener(MouseEvent.MOUSE_DOWN, displayMission4);
			playBtn.addEventListener(MouseEvent.CLICK, startGame);
		}
		
		private function startGame(e:MouseEvent, autoStart:Boolean = true):void {
			game.startHunt(selectedLevel, e, autoStart);
		}
		
		private function displayMissionInstructions(e:MouseEvent = null):void {
			body.text = getCurrentLevelDescription(selectedLevel);
			title.text = getCurrentLevelTitle(selectedLevel);
			missions.selectMission(selectedLevel);
		}
		private function displayMission1(e:MouseEvent):void {
			body.text = kLevel1Instructions;
			title.text = kLevel1Title;
			selectedLevel = "LEVEL 1";
		}
		private function displayMission2(e:MouseEvent):void {
			body.text = kLevel2Instructions;
			title.text = kLevel2Title;
			selectedLevel = "LEVEL 2";
		}
		private function displayMission3(e:MouseEvent):void {
			body.text = kLevel3Instructions;
			title.text = kLevel3Title;
			selectedLevel = "LEVEL 3";
		}
		private function displayMission4(e:MouseEvent):void {
			body.text = kLevel4Instructions;
			title.text = kLevel4Title;
			selectedLevel = "LEVEL 4";
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
		public function displayTreasure(item:String, value:String, location:Number):void { 
			visible = true;
			gotoAndStop("treasure");
			title.text = "Treasure!";
			body.text = "You found the " + item + " worth " + value + " at location " + location + "!";
		}
		
		// display the prompt that comes up when you pull anchor
		public function displayRecap(arg:String):void {
			visible = true;
			gotoAndStop("recap");
			title.text = "Anchor Pulled!";		
			body.text = arg;
		}
		
		// display the help
		public function displayHelp():void {
			visible = true;
			gotoAndStop("help");
			title.text = getCurrentLevelTitle();
			body.text = getCurrentLevelDescription();
		}
		
		// returns the name of the current level
		public function getCurrentLevelTitle(arg:String = null):String
		{
			var switcher:String = (arg ? arg : game.getCurrentMission());
			switch(switcher)
			{
				case "LEVEL 1":
					return kLevel1Title;
				case "LEVEL 2":
					return kLevel2Title;
				case "LEVEL 3":
					return kLevel3Title;
				case "LEVEL 4":
					return kLevel4Title;
			}
			return "";
		}
		
		//returns the current level description
		public function getCurrentLevelDescription(arg:String = null):String
		{
			var switcher:String = (arg ? arg : game.getCurrentMission());
			switch(switcher)
			{
				case "LEVEL 1":
					return PopUpMVC.kLevel1Instructions;
				case "LEVEL 2":
					return PopUpMVC.kLevel2Instructions;
				case "LEVEL 3":
					return PopUpMVC.kLevel3Instructions;
				case "LEVEL 4":
					return PopUpMVC.kLevel4Instructions;
			}
			return "";
		}
		
		
		// ---- FX SECTION ------------
		// ----------------------------
		
		// call this to make the popUpWindow fade out. 
		public function fadeOut():void {
			delayTimer.addEventListener(TimerEvent.TIMER, fadeOutInner);
			delayTimer.start();
		}
		
		private function fadeOutInner(e:Event):void {
			addEventListener(Event.ENTER_FRAME, reduceAlpha);
		}
		
		private function reduceAlpha(e:Event):void {
			
			alpha -= 0.05;
			if(alpha <= 0) {
				alpha = 1;
				visible = false;
				removeEventListener(Event.ENTER_FRAME, reduceAlpha);
				delayTimer.removeEventListener(TimerEvent.TIMER, fadeOutInner);
			}
		}
	}
}