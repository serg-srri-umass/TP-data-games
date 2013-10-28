package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class ReplayHook extends MovieClip{
		public static var HOOK_SIZE:int = 1;
		private const HOOK_Y:Number = -56.75;	// the Y value at which to attach hooks.
		private var _label:String;
		
		public function ReplayHook(position:Number = 0, treasure:Boolean = false, junk:String = null, treasureOffset:Number = 0) {
			x = position;
			y = HOOK_Y;
						
			_label = (treasure ? "hit" : "miss");
			gotoAndStop(_label);
			
			// show any junk you may have found.
			if(!treasure){
				if(junk == "got_boot"){
					junkMVC.gotoAndStop("boot");
				}else if(junk == "got_seaweed"){
					junkMVC.gotoAndStop("seaweed");
				}
			}else{
				Chest.chest.x = treasureOffset
			}
		}
		
		override public function play():void{
			gotoAndPlay(_label);
		}
		
		public function reset():void{
			gotoAndStop(_label);
		}
		
		public function get treasure():Boolean{
			return _label == "hit";
		}
		
		public static function setHookSize(arg:int):void{
			HOOK_SIZE = arg;
		}
	}
	
}
