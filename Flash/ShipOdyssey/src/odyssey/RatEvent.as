package odyssey
{
	import flash.events.Event;
	
	public class RatEvent extends Event
	{
		public static const RELEASED:String = "release";	// The button's been pressed, and the rats are being released.
		public static const RETURNED:String = "return";		// The animation is now over, and all the rats are back on deck.
		public static const CANCELLED:String = "cancelled";	// The animation was cancelled.
		
		// this is the default Event constructor. Don't fiddle with it if you don't have to.
		public function RatEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false):void
		{
			super(type, bubbles, cancelable);	
		}
	}
}