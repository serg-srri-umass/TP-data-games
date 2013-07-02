package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class ReplayHook extends MovieClip{
		
		private const HOOK_Y:Number = -56.75;	// the Y value at which to attach hooks.
		private var _label:String;
		
		public function ReplayHook(position:Number = 0, treasure:Boolean = false) {
			x = position;
			y = HOOK_Y;
			
			if(treasure)
				_label = "hit";
			else
				_label = "miss";
				
			gotoAndStop(_label);
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
	}
	
}
