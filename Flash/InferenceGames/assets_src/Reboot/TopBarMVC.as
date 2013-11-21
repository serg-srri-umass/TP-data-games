package  {
	
	import flash.display.MovieClip;
	
	
	public class TopBarMVC extends MovieClip {
		
		
		public function TopBarMVC() {
			// constructor code
		}
		
		public function earnPoint():void{
			myScoreMVC.nextFrame();
		}
		
		public function resetScore():void{
			myScoreMVC.gotoAndStop(1);
		}
		
		public function loseLife( newLifeTotal:int):void{
			lifeMVC.nextFrame();
		}
		
		public function resetLife( startingLife:int):void{
			lifeMVC.gotoAndStop(1);
		}
		
		public function setTitleMessage( arg:String):void{
			levelTxt.text = arg;
		}
	}
	
}
