package odyssey.events
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class BootyEventDispatcher extends EventDispatcher
	{
		public function dispatchAccounting(e:Event = null):void
		{
			dispatchEvent (new BootyEvent( BootyEvent.ACCOUNTING));
		}
		
		public function dispatchWin(e:Event = null):void
		{
			dispatchEvent (new BootyEvent( BootyEvent.WIN));
		}
		
		public function dispatchLose(e:Event = null):void
		{
			dispatchEvent (new BootyEvent( BootyEvent.LOSE));
		}
	}
}