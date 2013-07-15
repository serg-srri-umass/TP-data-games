package{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class BootyMeterCostBar extends MovieClip{
		private const BAR_HEIGHT:int = 160;	// the booty bar is 160px high.
		private const ANIMATION_CONST:int = 3; // how many px/frame the bar animates at
		
		public var goal:int; // the goal $.
		public var turned:Boolean;	// whether the arrow has "turned over".
		public var holdingCost:int; // used to hold the cost when the top is animating.
		public var costsSoFar:int;
		
		public function BootyMeterCostBar(){
			top.addEventListener("arrow_OVER", startDropping);
		}
		
		public function establish(treasureValue:int, goal_in:int):void{
			var costHeight:Number = (treasureValue/goal_in*BAR_HEIGHT);	//calculate how tall the treasure bar is.
			
			upBar.height = costHeight;	// set up all the other bars
			downBar.y = -costHeight;
			top.y = -costHeight;			
			downArrow.y = top.y;			
			top.gotoAndStop(1);
			
			downBar.visible = false;
			downArrow.visible = false;
			
			turned = false; // the bar hasn't started to go down yet.
			costsSoFar = 0;
			goal = goal_in;
		}
		
		public function pay(cost:int):void {
			if(!turned) {
				// if the arrow hasn't turned over yet, animate that first.
				turned = true;
				holdingCost = cost;
				turnOver();
			} else {
				costsSoFar += cost;
				addEventListener(Event.ENTER_FRAME, animateCost);
			}
		}
		
		private function turnOver():void{
			top.gotoAndPlay(1);
			turned = true;
		}
		
		private function startDropping(e:Event):void {	// this event triggers when the top finishes turning over
			downArrow.visible = true;
			downBar.visible = true;
			downBar.height = 1;
			pay(holdingCost);
		}
		
		private function animateCost(e:Event):void {
			var costHeight:Number = (costsSoFar/goal*BAR_HEIGHT);
			downBar.height += ANIMATION_CONST;
			if(downBar.height > costHeight) {
				downBar.height = costHeight;
				removeEventListener(Event.ENTER_FRAME, animateCost);
			}
			downArrow.y = downBar.y + downBar.height;			
		}
	}
}
