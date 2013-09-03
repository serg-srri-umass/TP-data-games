package odyssey.events
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	// dispatches rat related events. 
	public class RatEventDispatcher extends EventDispatcher
	{				
		public function dispatchReleased(e:Event= null):void
		{			
			// call this method when you've sent out the rats.
			dispatchEvent( new RatEvent( RatEvent.RELEASED));	
		}
		
		public function dispatchReturned(e:Event= null):void
		{
			dispatchEvent( new RatEvent( RatEvent.RETURNED));	
		}
		
		public function dispatchCancelled( e:Event = null):void
		{
			dispatchEvent (new RatEvent ( RatEvent.CANCELLED));
		}
	}
}