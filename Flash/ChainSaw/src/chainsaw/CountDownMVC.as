package chainsaw{
	
	public class CountDownMVC extends countDown{
		
		import flash.events.*;
		
		public static const FINISHED_PLAYING:String = "finishedPlaying";
		
		public function CountDownMVC(){
			super();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void{
			if(currentFrame == totalFrames){
				dispatchEvent(new Event(FINISHED_PLAYING));
			}
		}
	}
}