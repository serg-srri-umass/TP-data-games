package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	// this class handles the "camera" of the replay window.
	public class ReplayWindow extends MovieClip{
		
		static const SCREEN_BUFFER:int = 80;
		static const SCREEN_WIDTH:Number = 415;
		
		var targetPos:Number;
		
		public function ReplayWindow() {
			//foreground.addEventListener("treasurePlaced", measureToTreasure);
			foreground.addEventListener("replayStart", measureToHook);
			addEventListener("hookComplete", measureToHook);
		}
		
		private function measureToTreasure(e:Event = null):void{
			var pt:Point = new Point(foreground.x1.x, foreground.x1.y);
			pt = foreground.localToGlobal(pt);
			measure(pt.x, true);
		}
		
		private function measureToHook(e:Event = null):void{
			var h:ReplayHook = foreground.peekAtNextHook();
			if(!h)	//if there's nothing in the array, don't go any farther.
				return;
			
			var pt:Point = new Point(h.x, h.y);
			pt = foreground.localToGlobal(pt);
			measure(pt.x, h.treasure);
		}
			
		private function measure(ptX:Number, center:Boolean = false):void{
			if(center || ptX < SCREEN_BUFFER || ptX > (SCREEN_WIDTH - SCREEN_BUFFER)){	// if the next hook is going to be off camera, or is a treasure chest.
				
				targetPos = foreground.x + (200 - ptX);
				if(targetPos < ReplayForeground.MIN_X)
					targetPos = ReplayForeground.MIN_X;
				else if(targetPos > ReplayForeground.MAX_X)
					targetPos = ReplayForeground.MAX_X;
				
				addEventListener(Event.ENTER_FRAME, scroll);
			}
		}
		
		private function scroll(e:Event):void{
			foreground.x += (targetPos - foreground.x)/10;
			bkg.x += (targetPos - foreground.x)/15;
			if(Math.abs(foreground.x - targetPos) < 5)
				removeEventListener(Event.ENTER_FRAME, scroll);
		}

	}
	
}
