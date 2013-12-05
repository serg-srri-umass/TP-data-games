package{
	import flash.display.MovieClip;
	public class BoatSailAnimCrane extends MovieClip{
		public function BoatSailAnimCrane(){
			stop();
		}
		
		override public function gotoAndStop(frame:Object, scene:String = null):void{
			crane.gotoAndStop(frame);
			ring1.gotoAndStop(frame);
			ring2.gotoAndStop(frame);
			ring3.gotoAndStop(frame);
			super.gotoAndStop(frame);
		}
		
		override public function stop():void{
			crane.stop();
			ring1.stop();
			ring2.stop();
			ring3.stop();
			super.stop();
		}
		
		override public function nextFrame():void{
			crane.nextFrame();
			ring1.nextFrame();
			ring2.nextFrame();
			ring3.nextFrame();
			super.nextFrame();
		}
		
		override public function prevFrame():void{
			crane.gotoAndStop( crane.currentFrame - 1);
			ring1.gotoAndStop( ring1.currentFrame - 1);
			ring2.gotoAndStop( ring2.currentFrame - 1);
			ring3.gotoAndStop( ring3.currentFrame - 1);
			super.gotoAndStop( currentFrame - 1);
		}
		
		override public function play():void{
			crane.play();
			ring1.play();
			ring2.play();
			ring3.play();
			super.play();
		}
	}
}