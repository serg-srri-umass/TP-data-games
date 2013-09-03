package chainsaw.events
{
	import flash.events.Event;
	
	public class ChainsawEvent extends Event
	{
		
		public static const MOUSE_OUT_WINDOW:String = "mouseOutWindow";
		
		public function ChainsawEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}