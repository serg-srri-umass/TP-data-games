package odyssey
{
	import common.TextFormatter;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import odyssey.missions.Missions;
	
	public class PopUpScroll extends popUps
	{
		private var game:ShipMissionAPI;	//reference to the main. Allows this class to directly interact with the application.
		private var selectedLevel:int = 1;
		
		private var printedTreasures:int = 0; // how many treasures it says you have.
		private var _treasuresFound:int = 0; // how many treasures you found this mission.
		private var _rating:int = 1;	
		
		private var okayFunc:Function = emptyFunction;	// the funciton that's assigned to the okay button
		private function emptyFunction():void{}
		public var deleteData:Boolean = true;
		
		public function PopUpScroll(api:ShipMissionAPI = null) {
			game = api;
		}
		
		public function showLoading():void{
			visible = true;
			gotoAndStop("load");
		}
		
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
				throw new Error("treasuresFound must be positive");
			_treasuresFound = arg;
		}
		
		// this shows the final screen (how many treasures you got, your star rating, etc).
		public function displayGameOver(e:Event = null):void{
			visible = true;
			gotoAndStop("finishMission"); // TO-DO: rename this to gameOver
			mainBtn.addEventListener(MouseEvent.CLICK, okayGameOver);
			
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
		
		// the 'continue' button, for when you've won the game.
		private function okayGameOver(e:MouseEvent):void{
			mainBtn.removeEventListener(MouseEvent.CLICK, okayGameOver);
			game.closeGame();
			displayMissionMap(true);
		}
		
		// select what level will be played.
		public function displayMissionMap(skipAnimation:Boolean = true):void {
			game.setGameTitle("Choose a Mission");
			
			visible = true;
			gotoAndStop("level");
			displayMissionInstructions(null, skipAnimation);
			
			for(var i:int = 1; i <= 6; i++){
				missions["mission"+i].buttonMode = true; // turns the cursor into a hand on mouse over.
				missions["mission"+i].addEventListener(MouseEvent.MOUSE_UP, this["displayMission"+i]);
				
				var myBestRating:int = Missions.getMission(i).bestRating;
				missions["mission"+i].rating.gotoAndStop(myBestRating);
				missions["mission"+i].rating.visible = (myBestRating > 0);
			}
			
			missions.ghostBlocker.addEventListener(MouseEvent.DOUBLE_CLICK, startGame);
			missions.ghostBlocker.doubleClickEnabled  = true;
			missions.ghostBlocker.buttonMode = true;
			
			playBtn.addEventListener(MouseEvent.CLICK, startGame);
		}
		
		private function toggleDeletion(e:MouseEvent):void{
			deleteData = deleteDataBox.checked;	
		}
		
		private function startGame(e:MouseEvent):void {
			trace("starting game...");
			game.startHunt(selectedLevel, e);
		}
		
		private function displayMissionInstructions(e:MouseEvent = null, skipAnimation:Boolean = true):void {
			body.text = getCurrentLevelDescription(selectedLevel);
			titleBar.gotoAndStop(selectedLevel);
			missions.choose((selectedLevel == 6) ? selectedLevel-1:selectedLevel, skipAnimation);
		}
		
		private function displayMission1(e:MouseEvent):void {
			body.text = Missions.getMission(1).instructions;
			selectedLevel = Missions.getMission(1).number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		private function displayMission2(e:MouseEvent):void {
			body.text = Missions.getMission(2).instructions;
			selectedLevel = Missions.getMission(2).number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		private function displayMission3(e:MouseEvent):void {
			body.text = Missions.getMission(3).instructions;
			selectedLevel = Missions.getMission(3).number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		private function displayMission4(e:MouseEvent):void {
			body.text = Missions.getMission(4).instructions;
			selectedLevel = Missions.getMission(4).number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		private function displayMission5(e:MouseEvent):void {
			body.text = Missions.getMission(5).instructions;
			selectedLevel = Missions.getMission(5).number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		private function displayMission6(e:MouseEvent):void{ 
			body.text = Missions.getMission(6).instructions;
			selectedLevel = Missions.getMission(6).number;
			titleBar.gotoAndStop(selectedLevel);
		}
		
		//remove all listeners from the level chooser window & close it.
		public function stripMissionButtonListeners():void {
			visible = false;
			for(var i:int = 1; i <= 6; i++){
				missions["mission"+i].removeEventListener(MouseEvent.MOUSE_UP, this["displayMission"+i]);
			}		
			playBtn.removeEventListener(MouseEvent.CLICK, startGame);
		}
		
		
		// display the instant replay.
		public function displayInstantReplay(arg:String, func:Function, okay:Boolean = false):void {
			visible = true;
			gotoAndStop("recap");
			okayFunc = func;
			body.text = arg;
			okayBtn.visible = okay;
			nextSiteBtn.addEventListener(MouseEvent.CLICK, useOkayFunc);
			okayBtn.addEventListener(MouseEvent.CLICK, useOkayFunc);
			doReplayPrivate();
			
			deleteDataBox.checked = deleteData;
			deleteDataBox.addEventListener(MouseEvent.CLICK, toggleDeletion);
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
		
		public function displayMessage(title:String, message:String):void{
			visible = true;
			gotoAndStop("help");
			this.title.text = title;
			body.text = message;
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
		
		
		// REPLAY CODE:
		
		private var replayArray:Array = new Array();
		private var treasuresArray:Vector.<Treasure>;
		private var hasSeaWalls:Boolean;
		
		public function doReplay(arg:Array, treasuresArg:Vector.<Treasure>, hasSeaWalls:Boolean):void{
			replayArray = arg;
			treasuresArray = treasuresArg;
			this.hasSeaWalls = hasSeaWalls;
		}
		
		private function doReplayPrivate():void{
			replayWindow.foreground.reset();
			replayWindow.foreground.seaWalls.visible = hasSeaWalls;
			
			var t1:Number = -1;
			var t2:Number = -1;
			
			if(treasuresArray.length == 1){
				t1 = treasuresArray[0].location;
			} else if(treasuresArray.length == 2) {
				t1 = treasuresArray[0].location;
				t2 = treasuresArray[1].location;
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
		
		// CONFIRM ACTION
		
		// this function brings up the confirm dialog. If you click 'okay', it will perform arg. If you cancel, nothing will happen. 
		public function confirmAction(arg:Function):void{
			visible = true;
			okayFunc = arg;
			gotoAndStop("confirm");
			mainBtn.addEventListener(MouseEvent.CLICK, useOkayFunc);
			noBtn.addEventListener(MouseEvent.CLICK, cancelAction);
			
			deleteDataBox.checked = deleteData;
			deleteDataBox.addEventListener(MouseEvent.CLICK, toggleDeletion);
		}
		
		private function cancelAction(e:Event):void{
			visible = false;
		}
		
	}
}
