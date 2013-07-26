package odyssey
{
	import common.TextFormatter;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import odyssey.events.BootyEventDispatcher;
	
	public class BootyBarMVC extends BootyMeter
	{		
		private var _isGameOver:Boolean = false; // whether or not the game is over.
		
		private var _dispatcher:BootyEventDispatcher = new BootyEventDispatcher(); // object that dispatches booty events		
		
		private var _goal:int;  // how many treasures the player needs to win the level.
		private var _treasuresFound:int; // how many treasures the player has
		
		private var _gold:int; // how much gold the player has to spend.
		private var _startingGold:int; // how much gold the player started the mission with.
		private var targetHeight:Number; // the height that the booty bar is trying to animate to.
		
		public function BootyBarMVC()
		{
			nextSiteBtn.addEventListener(MouseEvent.CLICK, donextSiteFunc);
			endMissionBtn.addEventListener(MouseEvent.CLICK, doEndMissionFunc);
			
			var tf:TextFormat = new TextFormat();
			tf.bold = true;
			treasureDisplay.treasure.treasures.defaultTextFormat = tf;
			goldMeter.gold.defaultTextFormat = tf;
		}
		
		public function get dispatcher():BootyEventDispatcher
		{
			return _dispatcher;
		}
		
		public function get gold():int{
			return _gold;
		}
		
		public function get goal():int{
			return _goal;
		}
		
		public function get startingGold():int{
			return _startingGold;
		}
		
		public function get treasuresFound():int{
			return _treasuresFound;
		}
		
		public function get isGameOver():Boolean{
			return _isGameOver;
		}
		
		// when a hook drop finishes, this method runs. 
		public function finishTreasureDrop(success:Boolean):void{
			if( success){
				getTreasure();
			} else{
				_isGameOver = (_gold <= 0);
				if(_isGameOver){
					_dispatcher.dispatchEmpty();
				}
			}
		}
		
		// get a treasure.
		private function getTreasure():void{
			_treasuresFound++;
			treasureDisplay.gotoAndPlay("flash");
			treasureDisplay.treasure.treasures.text = String(_treasuresFound);
			if(treasuresFound >= _goal){
				_isGameOver = true;
				_dispatcher.dispatchWin();		// the game is over, and you win!
			}
		}
		
		// call this method at the start of each level
		public function initialize(startingGold:int, goal:int = 0):void
		{
			// first, set all the numbers:
			_isGameOver = false;
			_startingGold = startingGold;
			_gold = _startingGold;
			_goal = (goal == 0 ? int.MAX_VALUE : goal);
			_treasuresFound = 0;
			goldMeter.maskObj.height = 101;
			treasureDisplay.treasure.treasures.text = String(_treasuresFound);	// write the # of treasures you have at the top.
			goldMeter.gold.text = String(_gold);		// write how much gold you have in the bar.
			
		}
		
		// call this method whenever you spend money
		public function pay(cost:int):void{
			_gold -= cost;
			if(_gold <= 0) // stop it from going negative.
				_gold = 0;
			
			goldMeter.gold.text = String(_gold); //wip.
			account();
		}
		
		private function account():void{
			targetHeight = (_gold/_startingGold)*100 + 1;
			addEventListener(Event.ENTER_FRAME, animateGold);
		}
		
		private function animateGold(e:Event):void{
			if(targetHeight + 0.1 < goldMeter.maskObj.height){
				goldMeter.maskObj.height -= (goldMeter.maskObj.height - targetHeight)/5;
			}else{
				goldMeter.maskObj.height = targetHeight;
				removeEventListener(Event.ENTER_FRAME, animateGold);
			}
		}
		
		private var _endMissionFunc:Function;
		public function set endMissionFunction(arg:Function):void{
			_endMissionFunc = arg;
		}
		public function get endMissionFunction():Function{
			return _endMissionFunc;
		}
		private function doEndMissionFunc(e:Event):void{
			_endMissionFunc(e);
		}
		
		private var _nextSiteFunc:Function;
		public function set nextSiteFunction(arg:Function):void{
			_nextSiteFunc = arg;
		}
		public function get nextSiteFunction():Function{
			return _nextSiteFunc;
		}
		private function donextSiteFunc(e:Event):void{
			_nextSiteFunc(e);
		}
		
		public function disableNextSiteButton(fade:Boolean = true):void{
			if(fade){
				nextSiteBtn.alpha = 0;
				removeEventListener(Event.ENTER_FRAME, animateNextSiteBtnIn);
			}else{
				nextSiteBtn.alpha = 0.5;
			}
			nextSiteBtn.mouseEnabled = false;
		}
		
		public function enableNextSiteButton(fade:Boolean = true):void{
			nextSiteBtn.mouseEnabled = true;
			if(fade){
				addEventListener(Event.ENTER_FRAME, animateNextSiteBtnIn);
			}else{
				nextSiteBtn.alpha = 1;
			}
		
		}
		public function disableEndMissionButton():void{
			endMissionBtn.alpha = .5;
			endMissionBtn.mouseEnabled = false;
		}
		
		public function enableEndMissionButton():void{
			endMissionBtn.alpha = 1;
			endMissionBtn.mouseEnabled = true;
		}
		
		// this code fades in the next site button
		private function animateNextSiteBtnIn(e:Event):void{
			if(nextSiteBtn.alpha < 1)
				nextSiteBtn.alpha += 0.1;
			else
				removeEventListener(Event.ENTER_FRAME, animateNextSiteBtnIn);
		}
	}
}