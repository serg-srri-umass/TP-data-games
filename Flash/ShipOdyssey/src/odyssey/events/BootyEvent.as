package odyssey.events
{
	import flash.events.Event;

	public class BootyEvent extends Event
	{
		public static const ACCOUNTING:String = "accounting";
		public static const WIN:String = "win";
		public static const EMPTY:String = "lose";
			
		// this is the default Event constructor. Don't fiddle with it if you don't have to.
		public function BootyEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false):void
		{
			super(type, bubbles, cancelable);	
		}
	}
}