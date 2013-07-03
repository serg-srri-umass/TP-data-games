package{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.Timer;

	public class CraneAnimationDropHook extends MovieClip{
		private var junkArray:Array;
		private var junkChance:int = 40;
		
		public function CraneAnimationDropHook(){
			super();
			stop();
			junkArray = new Array(Boot, DarkMass, DarkMass);
		}
		
		public function showRandom(){
			var randomPickUp:int = Math.random()*100;
			if(randomPickUp < junkChance) {	// you grabbed junk.
				var junkIndex:int = Math.random()*junkArray.length;
				if(junkArray[junkIndex] == Boot){
					Boot.visible = true;
					dispatchEvent( new Event("got_boot", true));
				}else {
					DarkMass.visible = true;
					dispatchEvent (new Event("got_seaweed", true));
				}
			}else{
				dispatchEvent (new Event("got_nothing", true));
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