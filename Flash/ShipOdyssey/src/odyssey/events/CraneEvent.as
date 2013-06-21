package odyssey.events
{
	import flash.events.Event;
	
	public class CraneEvent extends Event
	{
		
		public static const STOWED:String = "stowed" //The crane has been stowed, and is now facing the nose of the boat
			
		public function CraneEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			super(type, bubbles, cancelable);
		}
	}
}