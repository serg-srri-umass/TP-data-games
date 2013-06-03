package odyssey
{
	import flash.events.Event;
	
	public class BootyBarMVC extends BootyMeter
	{
		private var BAR_HEIGHT:Number; 
		
		private var _booty:int;				// how much booty the player currently has
		private var _startingBooty:int;		// how much booty the player had at the start of a location
		private var _capital:int;			// how much booty the player started the level with
		private var _goal:int;				// how much booty the player needs to win
		private var _treasureValue:int;		// how much booty the treasure is worth on this level
		private var _costs:int;				// how many costs have racked up this location
		
		private var targetFrame:int; //used for animation logic
		private var displayBooty:int; //used for animation logic. Animated $
		private var _settingStartValue:Boolean; // animation logic. when it's true, the starting value will move along with the $.
		
		private var _ghostCost:int;	//used for displaying prices when the mouse is hovering over a button
		
		public function BootyBarMVC()
		{
			addEventListener(Event.ADDED_TO_STAGE, turnOff); 
			BAR_HEIGHT = barBacking.height
		}
		
		public function get booty():int
		{
			return _booty;
		}
		public function set booty(arg:int):void{
			_booty = arg;
		}
		public function get goal():int{
			return _goal;
		}
		public function get treasureValue():int{
			return _treasureValue;
		}
		public function get startingBooty():int{
			return _startingBooty;
		}
		public function get profit():int{
			return _treasureValue - _costs;
		}
		
		private function turnOff(e:Event = null):void
		{
			// set the movieclip to its "off" state (grayed out) when its created.
			gotoAndStop(1);
			goalMVC.text = "$0";
			myCash.booty.text = "";
			costBar.visible = false;
		}
		
		public function ghost(cost:int):void
		{
			pay(cost, true);
			_ghostCost = cost;
		}
		public function cancelGhost():void
		{
			if(_ghostCost > 0)
				pay(-_ghostCost);
			_ghostCost = 0;	
		}
		// call this method at the start of each level
		public function initialize(capital:int, goal:int, treasureValue:int):void
		{
			// first, set all the numbers:
			_capital = capital;
			_goal = goal;
			_treasureValue = treasureValue;
			_booty = _capital;	
			_startingBooty = _capital;
			_costs = 0;
			
			goalMVC.text = parseToCash(_goal);	// write the goal at the top
			animateBooty(true);
			prepCostBar();
		}
		
		// call this method whenever you spend money
		public function pay(cost:int, ghost:Boolean = false):void
		{
			_costs += cost;	
			var percentCosts:Number = (_treasureValue - _costs)/_treasureValue;
			if(!ghost)
			{
				costBar.ghostBar1.visible = false;
				costBar.ghostBar2.visible = false;
				if(percentCosts >= 0) // positive profits
				{
					costBar.redBar.visible = false;
					costBar.profitBar.visible = true;
					
					costBar.profitBar.height = costBar.backingBar.height * percentCosts;
					costBar.ghostBar1.height = costBar.profitBar.height;
				} else { // going into the red
					costBar.profitBar.visible = false;
					costBar.redBar.visible = true;
					costBar.redBar.height = costBar.backingBar.height * -1 * percentCosts;
				}
			} else
			{
				// if the payment is a ghost, move the regular bars, but keep the white ghost bars in place
				if(percentCosts >= 0) // positive profits
				{
					costBar.ghostBar1.visible = true;
					costBar.ghostBar2.visible = false;
					costBar.profitBar.height = costBar.backingBar.height * percentCosts;
				} else { // going into the red
					costBar.ghostBar1.visible = costBar.profitBar.visible;
					costBar.profitBar.visible = false;
					costBar.ghostBar2.visible = true;
					costBar.ghostBar2.height = costBar.backingBar.height * -1 * percentCosts;
				}
			}
		}
		
		// call this method at the start of each location
		public function readyNewLocation():void
		{
			_startingBooty = _booty;
			animateBooty(true);
			prepCostBar();
			_costs = 0;
			cancelGhost();
		}
		
		// merge the costs into the booty meter.
		public function account(gotTreasure:Boolean = true):void{
			if(gotTreasure)
				_booty += treasureValue;
			_booty -= _costs;
			animateBooty();
			_costs = 0;
			cancelGhost();
		}
		
		// set up the cost bar for a new location
		private function prepCostBar():void
		{
			costBar.visible = true;
			costBar.backingBar.height = BAR_HEIGHT*(getPercent(treasureValue)/100);
			costBar.profitBar.height = costBar.backingBar.height;
			costBar.redBar.visible = false;
			costBar.profitBar.visible = true;
			costBar.ghostBar1.visible = false;
			costBar.ghostBar2.visible = false;
			costBar.ghostBar1.height = costBar.profitBar.height;
			
		}
		
		private function animateBooty(setStartingValue:Boolean = false):void
		{
			var arg:int = getPercent(_booty)*10;	// convert percent to per thousand
			_settingStartValue = setStartingValue;
			
			// safety net: if the bar is currently animating, it will cancel that animation before starting a new one
			if(hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, subAnimateBooty);
			
			targetFrame = arg;
			addEventListener(Event.ENTER_FRAME, subAnimateBooty);
		}
		private function subAnimateBooty(e:Event):void
		{
			var dist:Number = (targetFrame - currentFrame)/10;
			dist = (targetFrame > currentFrame ? Math.ceil(dist) : Math.floor(dist));
			// rounding is based on whether the graph is moving up or down
			
			
			gotoAndStop(currentFrame + dist);
			myCash.booty.text = parseToCash((_goal*currentFrame)/1000);
			
			if(_settingStartValue)
				costBar.y = barPosition.y;
			
			if(currentFrame == targetFrame)
			{
				_settingStartValue = false;
				myCash.booty.text = parseToCash(_booty);
				removeEventListener(Event.ENTER_FRAME, subAnimateBooty);	
			}
			
		}
		
		// give this method a number, and it will return it in readable format. 3000 --> $3,000
		private function parseToCash(arg:int):String
		{
			var stringArg:String = String(arg);
			var outputString:String = "$";
			var backwardsString:String = "";
			var ticker:int = 0;
			
			for( var i:int = stringArg.length; i >= 0; i--){
				backwardsString += stringArg.charAt(i);
				if(ticker == 3 && i > 0){
					backwardsString += ",";
					ticker = 0;
				}
				ticker++;
			}
			for( var j:int = backwardsString.length; j >= 0; j--)
				outputString += backwardsString.charAt(j);
			
			return outputString;
		}
		
		// given a booty, this method returns what % it is of the goal
		private function getPercent(arg:int):int{
			var percent:int = (arg/_goal)*100;
			return percent;
		}
	}
}