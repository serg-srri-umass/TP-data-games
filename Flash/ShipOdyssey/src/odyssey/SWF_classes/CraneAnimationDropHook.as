package{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.Timer;

	public class CraneAnimationDropHook extends MovieClip{
		private var junkArray:Array;
		private var junkChance:int = 100;
		
		public function CraneAnimationDropHook(){
			super();
			stop();
			junkArray = new Array(Boot, DarkMass)
		}
		
		public function showRandom(){
			var randomPickUp:int = Math.random()*100;
			if(randomPickUp < junkChance) {
				var junkIndex = Math.floor(Math.random()*junkArray.length);
				junkArray[junkIndex].visible = true;
			}
		}
		
		public function showTreasure(){
			Chest.visible = true;
		}
		
		public function hideAll(){
			Chest.visible = false;
			for(var i:int = 0; i<junkArray.length; i++){
				junkArray[i].visible = false;
			}
		}
	}
}