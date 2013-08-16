// USED IN: gameScreen.fla

package{
	
	import flash.events.Event;
	
	public class AnimationEvent extends Event
	{
		public static const COMPLETE_HIDE:String = "ctoff";
		public static const COMPLETE_SHOW:String = "cton";
		
		public function AnimationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}