package odyssey
{
	import flash.events.EventDispatcher;
	
	// dispatches rat related events. 
	public class RatEventDispatcher extends EventDispatcher
	{				
		public function dispatchReleased():void
		{			
			// call this method when you've sent out the rats.
			dispatchEvent(new RatEvent(RatEvent.RELEASED));	
		}
		
		public function dispatchReturned():void
		{
			dispatchEvent(new RatEvent(RatEvent.RETURNED));	
		}
	}
}