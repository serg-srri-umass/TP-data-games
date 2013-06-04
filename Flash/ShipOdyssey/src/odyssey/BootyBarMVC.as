package odyssey
{
	//this class is pretty messy at the moment. After wednesday's demo, we can clean it up for easier readability.
	
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
		private var _holdingGhost:Boolean = false; //used to show that you could lose X amount of money if your hook drop misses
		
		public function BootyBarMVC()
		{
			addEventListener(Event.ADDED_TO_STAGE, turnOff); 
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			BAR_HEIGHT = barBacking.height
		}
		
		public function get booty():int
		{
			return _booty + _treasureValue - _costs + _ghostCost;
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
		public function get costs():int{
			return _costs;
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
			if(!_holdingGhost)		// cancel ghost has no effect while holding ghost.
			{
				if(_ghostCost > 0)
					pay(-_ghostCost);
				_ghostCost = 0;
			}
		}
		public function startTreasureDrop():void{
			_holdingGhost = true;
		}
		public function finishTreasureDrop(sucess:Boolean, cost:int = 0):Boolean{
			if(sucess)
			{
				_costs -= _ghostCost;
				_ghostCost = 0;
				_booty += treasureValue;
				account();
				if(_booty >= _goal)
					return true;
			}else
			{
				_holdingGhost = false;
				cancelGhost();
				pay(cost);
				if(_booty + _treasureValue - costs <= 0)
					return true;
			}
			return false;
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
			_holdingGhost = false;
			cancelGhost();
		}
		
		// merge the costs into the booty meter.
		public function account():void{
			_booty -= _costs;
			animateBooty();
			animateCost(true);
			_costs = 0;
			cancelGhost();
		}
		
		// set up the cost bar for a new location
		private function prepCostBar():void
		{
			costBar.visible = true;
			costBar.backingBar.height = BAR_HEIGHT*(getPercent(treasureValue)/100);
			costBar.profitBar.height = costBar.backingBar.height;
			costBar.profitBar.gotoAndStop(1);
			costBar.redBar.visible = false;
			costBar.redBar.height = 1;
			costBar.profitBar.visible = true;
			costBar.ghostBar1.visible = false;
			costBar.ghostBar2.visible = false;
			costBar.ghostBar1.height = costBar.profitBar.height;
			
		}
		
		private var _animateBooty:Boolean = false;
		private var _animateCost:int = 0;
		
		// this method is called every frame. It handles the animation logic
		private function handleEnterFrame(e:Event):void{
			if(_animateBooty)
				subAnimateBooty();
			
			if(_animateCost == 1)			// 0 = off. 1 = going up. 2 = going down
				subAnimateCost(true);
			else if(_animateCost == 2)
				subAnimateCost(false);
		}
		private function animateBooty(setStartingValue:Boolean = false):void
		{
			var arg:int = getPercent(_booty)*10;	// convert percent to per thousand
			_settingStartValue = setStartingValue;
			targetFrame = arg;
			_animateBooty = true;
		}
		private function subAnimateBooty():void
		{
			var dist:Number = (targetFrame - currentFrame)/10;
			if(targetFrame > totalFrames)
				targetFrame = totalFrames;
			
			dist = (targetFrame > currentFrame ? Math.ceil(dist) : Math.floor(dist));
			// rounding is based on whether the graph is moving up or down
			
			gotoAndStop(currentFrame + dist);
			
			if(((_goal*currentFrame)/1000) < 100)
			{
				myCash.booty.text = "$0";
			}else{
				myCash.booty.text = parseToCash((_goal*currentFrame)/1000);
			}
			
			if(_settingStartValue)
				costBar.y = barPosition.y;
			
			if(currentFrame == targetFrame)
			{
				_settingStartValue = false;
				myCash.booty.text = parseToCash(_booty);
				_animateBooty = false;
			}
		}
		
		private function animateCost(goingUp:Boolean):void
		{
			if(goingUp)
				_animateCost = 1;
			else
				_animateCost = 2;
		}
		private function subAnimateCost(goingUp:Boolean):void
		{
			if(goingUp)  // you found the treasure! Bring the profit bar back up to the ghost bar slowly.
			{ 
				// differant logic is required for the negative bar & the positive bar
				// the red bar & ghost bar 2:
				if(costBar.ghostBar2.visible)
				{
					if(costBar.redBar.visible){
						if(costBar.ghostBar2.height > costBar.redBar.height){
							costBar.ghostBar2.height -= 1;
						}else{
							_animateCost = 0;
							_holdingGhost = false;
							costBar.ghostBar2.height = costBar.redBar.height;
						}
					}else{
						if(costBar.ghostBar2.height > 1){
							costBar.ghostBar2.height -= 1;
						} else
						{
							costBar.ghostBar2.visible = false;
						}
					}
				} else	// the profit bar & ghost bar 1:
				{
					costBar.profitBar.visible = true;
					if(costBar.profitBar.height < costBar.ghostBar1.height)
					{
						costBar.profitBar.height += 1;
					}else
					{
						_animateCost = 0;
						_holdingGhost = false;
						costBar.profitBar.height = costBar.ghostBar1.height;
					}
				}
			} else{
				//work in progress. Won't be ready for wednesday.
				// the cost bar will slowly tick down, when you miss.
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