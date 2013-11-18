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
			lifeMVC.lostLifeMVC.hurtScoreTxt.text = String(newLifeTotal + 1);
			lifeMVC.myLifeTxt.text = newLifeTotal;
			lifeMVC.gotoAndPlay(1);
		}
		
		public function resetLife( startingLife:int):void{
			lifeMVC.myLifeTxt.text = startingLife;
			lifeMVC.lostLifeMVC.hurtScoreTxt.text = startingLife;
		}
	}
	
}
