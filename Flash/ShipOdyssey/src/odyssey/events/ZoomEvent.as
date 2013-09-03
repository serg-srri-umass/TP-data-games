package odyssey.events {
	
	import flash.events.Event;
	
	public class ZoomEvent extends Event {

		public static const OUT:String = "out";
		public static const IN:String = "in";
		
		public function ZoomEvent(type:String) {
			super(type, true);
		}

	}
	
}
