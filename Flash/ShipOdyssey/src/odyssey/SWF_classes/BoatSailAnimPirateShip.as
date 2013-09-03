package{
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class BoatSailAnimPirateShip extends MovieClip{
		
		public var rPlay:Boolean = false;

		public function BoatSailAnimPirateShip(){
			stop();

		}
		
		public function startSail():void{
			this.addEventListener(Event.ENTER_FRAME, playMe);
		}
		
		public function stopSail():void{
			this.addEventListener(Event.ENTER_FRAME, playReverse);
		}
		
		private function playMe(e:Event):void {
			if(this.currentFrame == 59){
				gotoAndStop(40);
			}else{
				this.nextFrame();
			}
		}
		private function playReverse(e:Event):void{
			this.removeEventListener(Event.ENTER_FRAME, playMe);
			if(this.currentFrame == 1){
				stopPlayReverse();
			}else if(!rPlay){
				if(this.currentFrame == 59){
					rPlay = true;
					this.gotoAndStop(40);
				}else{
					this.nextFrame();
				}
			}else{
				this.prevFrame();
			}
		}
		
		public function stopPlayReverse():void {
			if (this.hasEventListener(Event.ENTER_FRAME)){
				this.removeEventListener(Event.ENTER_FRAME, playReverse);
				rPlay = false;
			}
		}
	}
}





