package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class ReplayForeground extends MovieClip{
		
		public static const MAX_X:Number = 389;
		public static const MIN_X:Number = 202.15;
		
		var startingOffset:Number;	// how many px before the scale starts
		var incrementLength:Number; // how many px a single tick on the scale is
		
		private var hookArray:Array;	//where hook data is stored.
		private var recycleArray:Array;	//is used to loop the animation.
		private var removalArray:Array = new Array(); // used in unloading the movieclips.
		
		private var _x1Location:int = -1, _x2Location:int = -1;
		
		var startTimer:Timer = new Timer(1500, 1);
		var interTimer:Timer = new Timer(500, 1);
		var completeTimer:Timer = new Timer(2000, 1);
		
		public function peekAtNextHook():ReplayHook{
			return hookArray[0];
		}
		
		public function ReplayForeground() {
			startingOffset = startPos.x;
			incrementLength = (endPos.x - startPos.x)/100;
			
			hookArray = new Array();
			recycleArray = new Array();
			
			addEventListener("hookComplete", startInterTimer);
			startTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleReplay);
			interTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleReplay);
			completeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, restart);
		}
		
		public function placeTreasure(treasure1_location:Number = -1, treasure2_location:Number = -1){
			_x1Location = treasure1_location;
			_x2Location = treasure2_location;
			
			if(treasure1_location > 0) {
				x1.visible = true;
				x1.x = getScalePosition(treasure1_location);
				x1.position.text = treasure1_location.toFixed(1);
				dispatchEvent(new Event("treasurePlaced"));
			} else {
				x1.visible = false;
			}
				
			if(treasure2_location > 0) {
				x2.visible = true;
				x2.x = getScalePosition(treasure2_location);
				x2.position.text = treasure2_location.toFixed(1);
			} else {
				x2.visible = false;
			}
		}
		
		public function addHook(pos:Number, treasure:Boolean = false, junk:String = null):void{
			var treasureOffset:Number = 0;
			
			if(treasure){
				var distToX1:Number = 1000, distToX2:Number = 1000;
				if( _x1Location > -1)
					distToX1 = Math.abs( _x1Location - pos);
				if( _x2Location > -1)
					distToX2 = Math.abs( _x2Location - pos);
				
				trace("x1: " + distToX1);
				trace("x2: " + distToX2);
				if( distToX1 < distToX2){
					treasureOffset = (_x1Location - pos) * 5;
				} else if( distToX1 > distToX2){
					treasureOffset = (_x2Location - pos) * 5;
				}
				
			}
			
			var h:ReplayHook = new ReplayHook(getScalePosition(pos), treasure, junk, treasureOffset);
			addChild(h);
			hookArray.push(h);
			removalArray.push(h);
		}
		
		public function startReplay():void{
			var q:ReplayWindow = parent as ReplayWindow;
			q.replayText.gotoAndPlay(1);
			startTimer.reset();
			startTimer.start();
			dispatchEvent(new Event("replayStart"));
		}

		private function startInterTimer(e:Event):void{
			interTimer.reset();
			interTimer.start();
		}

		private function restart(e:Event):void{
			for(var i:int = 0; i < hookArray.length; i++)
				hookArray[i].reset();
			startReplay();
		}
		
		private function getScalePosition(arg:Number):Number{
			return arg*incrementLength + startingOffset;
		}
		
		private function handleReplay(e:Event = null):void{
			if(hookArray.length > 0){
				var h = hookArray.shift();
				h.play();
				recycleArray.push(h);
			}else if(recycleArray.length > 0){
				while(recycleArray.length > 0){
					hookArray.push( recycleArray.shift());
				}
					
				completeTimer.reset();
				completeTimer.start();
			}
		}
		
		public function reset():void{
			while(removalArray.length > 0)
				removeChild(removalArray.pop());
			hookArray = new Array();
			recycleArray = new Array();
		}

	}
}