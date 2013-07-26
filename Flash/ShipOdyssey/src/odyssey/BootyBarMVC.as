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
		
		private var _treasuresFound:int; // how many treasures the player has
		private var _missesAllowed:int;
		private var _misses:int;
		
		private var _gold:int; // how much gold the player has to spend.
		private var goldText:int; // what the display says.

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
		
		public function get misses():int{
			return _misses;
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
				_isGameOver = missHook();
				_dispatcher.dispatchEmpty();
			}
		}
		
		// get a treasure.
		private function getTreasure():void{
			_treasuresFound++;
			treasureDisplay.gotoAndPlay("flash");
			treasureDisplay.treasure.treasures.text = String(_treasuresFound);
		}
		
		// call this method at the start of each level
		public function initialize(startingGold:int, missesAllowed:int):void
		{
			// first, set all the numbers:
			_isGameOver = false;
			_startingGold = startingGold;
			_gold = _startingGold;
			
			_misses = 0;
			_missesAllowed = missesAllowed;
			
			_treasuresFound = 0;
			goldMeter.maskObj.height = 101;
			treasureDisplay.treasure.treasures.text = String(_treasuresFound);	// write the # of treasures you have at the top.
			
			goldText = _gold;
			goldMeter.gold.text = goldText;		// write how much gold you have in the bar.
			
			hooks.gotoAndStop(missesAllowed);
			for(var i:int = 0; i<missesAllowed; i++)
				hooks["hook"+(i+1)].gotoAndStop(1);		//shows the correct # of hooks, from 1 - 4
		}
		
		// call this method whenever you spend money
		public function pay(cost:int):void{
			_gold -= cost;
			if(_gold <= 0) // stop it from going negative.
				_gold = 0;
			
			account();
		}
		
		private function account():void{
			targetHeight = (_gold/_startingGold)*100 + 1;
			goldMeter.gold.text = String(goldText); //wip.
			addEventListener(Event.ENTER_FRAME, animateGold);
		}
		
		private var ANIMATION_SPEED:int = 5; // how fast the bar drops. Bigger # = slower drop.
		private function animateGold(e:Event):void{
			if(targetHeight + 0.1 < goldMeter.maskObj.height){
				var changeVar:Number = (goldMeter.maskObj.height - targetHeight)/ANIMATION_SPEED;
				goldMeter.maskObj.height -= changeVar;
				
				var changeDist:Number = (goldText - _gold)/ANIMATION_SPEED;
				goldText -= changeDist;
			}else{
				goldMeter.maskObj.height = targetHeight;
				removeEventListener(Event.ENTER_FRAME, animateGold);
				goldText = _gold;
			}
			goldMeter.gold.text = String(goldText);
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
		
		// this method is called when a hook misses. It updates the UI, and returns whether or not the game is over
		public function missHook():Boolean{
			_misses++;
			hooks["hook"+_misses].gotoAndPlay(1);
			if(_misses >= _missesAllowed){
				return true;
			}else{
				return false;
			}
		}
	}
}