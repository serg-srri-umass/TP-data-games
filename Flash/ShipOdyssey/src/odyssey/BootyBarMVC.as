package odyssey
{
	import common.TextFormatter;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import odyssey.events.BootyEventDispatcher;
	
	public class BootyBarMVC extends BootyMeter
	{		
		private var _dispatcher:BootyEventDispatcher = new BootyEventDispatcher(); // object that dispatches booty events		
		
		private var _treasuresFound:int; // how many treasures the player has
		private var _missesAllowed:int;
		private var _misses:int;
		
		private var _rats:int; // how many rats the player has to send.
		private var ratText:int; // what the display says.

		private var _startingRats:int; // how many rats the player started the mission with.
		private var targetHeight:Number; // the height that the booty bar is trying to animate to.

		private var _nextSiteFunc:Function;
		
		public function BootyBarMVC()
		{
			nextSiteBtn.addEventListener(MouseEvent.CLICK, donextSiteFunc);
			endMissionBtn.addEventListener(MouseEvent.CLICK, doEndMissionFunc);
			
			var tf:TextFormat = new TextFormat();
			tf.bold = true;
			treasureDisplay.treasure.treasures.defaultTextFormat = tf;
			ratMeter.rats.defaultTextFormat = tf;
		}
		
		public function get dispatcher():BootyEventDispatcher
		{
			return _dispatcher;
		}
		
		public function get rats():int{
			return _rats;
		}
		
		public function get misses():int{
			return _misses;
		}
		
		public function get startingRats():int{
			return _startingRats;
		}
		
		public function get treasuresFound():int{
			return _treasuresFound;
		}
		
		public function get isOutOfHooks():Boolean{
			return _misses >= _missesAllowed;
		}
		public function get isOutOfRats():Boolean{
			return _rats <= 0;
		}
		
		public function getNumRatsDropped():int {
			return _startingRats - _rats;
		}
		
		// when a hook drop finishes, this method runs. 
		public function finishTreasureDrop(success:Boolean):void{
			if( success){
				getTreasure();
			} else{
				missHook();
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
		public function initialize(startingRats:int, missesAllowed:int):void
		{
			// first, set all the numbers:
			_startingRats = startingRats;
			_rats = startingRats;
			
			_misses = 0;
			_missesAllowed = missesAllowed;
			
			_treasuresFound = 0;
			ratMeter.maskObj.height = 101;
			treasureDisplay.treasure.treasures.text = String(_treasuresFound);	// write the # of treasures you have at the top.
			
			ratText = _rats;
			ratMeter.rats.text = ratText;		// write how many rats you have in the bar.
			
			hooks.gotoAndStop(missesAllowed);
			for(var i:int = 0; i<missesAllowed; i++)
				hooks["hook"+(i+1)].gotoAndStop(1);		//shows the correct # of hooks, from 1 - 4
		}
		
		// call this method whenever you spend money
		public function pay(cost:int):void{
			_rats -= cost;
			if(_rats <= 0) // stop it from going negative.
				_rats = 0;
			
			account();
		}
		
		private function account():void{
			targetHeight = (_rats/_startingRats)*100 + 1;
			ratMeter.rats.text = String(ratText); //wip.
			addEventListener(Event.ENTER_FRAME, animateGold);
		}
		
		private var ANIMATION_SPEED:int = 5; // how fast the bar drops. Bigger # = slower drop.
		private function animateGold(e:Event):void{
			if(targetHeight + 0.1 < ratMeter.maskObj.height){
				var changeVar:Number = (ratMeter.maskObj.height - targetHeight)/ANIMATION_SPEED;
				ratMeter.maskObj.height -= changeVar;
				
				var changeDist:Number = (ratText - _rats)/ANIMATION_SPEED;
				ratText -= changeDist;
			}else{
				ratMeter.maskObj.height = targetHeight;
				removeEventListener(Event.ENTER_FRAME, animateGold);
				ratText = _rats;
			}
			ratMeter.rats.text = String(ratText);
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
		public function missHook():void{
			_misses++;
			hooks["hook"+_misses].gotoAndPlay(1);
		}
	}
}