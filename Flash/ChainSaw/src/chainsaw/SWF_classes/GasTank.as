package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
		
	public class GasTank extends MovieClip {
		
		public var dropTime = 240;
		public var gasLineInitY;
		public var dropDist;
		public var dropPerFrame;
		public var dropping:Boolean = false;
		public var i = 0;
		
		public function GasTank() {
			gasLineInitY = WavyGas.y;
			dropDist  = FuelLines.height;
			dropPerFrame = dropDist/dropTime;
			WavyGas.play();
		}
		
		public function initGasTank(frames:int):void{
			WavyGas.y = gasLineInitY;
			dropTime = frames;
			dropPerFrame = dropDist/dropTime;
		}
		public function resetDrop():void{
			WavyGas.y = gasLineInitY;
		}
		public function startDrop():void{
			WavyGas.addEventListener(Event.ENTER_FRAME, dropLevel);
			dropping = true;
		}
		public function pauseDrop():void{
			WavyGas.removeEventListener(Event.ENTER_FRAME, dropLevel);
			dropping = false;
		}
		
		private function dropLevel(e:Event):void{
			WavyGas.y += dropPerFrame;
			//i++;
			if (WavyGas.y>=gasLineInitY+dropDist){
				WavyGas.removeEventListener(Event.ENTER_FRAME, dropLevel);
				dropping = false;
				//WavyGas.stop();
			}
		}
	}
}