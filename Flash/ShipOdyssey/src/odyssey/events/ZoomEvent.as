package odyssey.events {
	
	import flash.events.Event;
	
	public class ZoomEvent extends Event {

		public static const OUT:String = "out";
		
		public static const IN:String = "in";
		
		private var _zoom:String = "none";
		
		public function get zoom():String {
			return _zoom;
		}

		public function ZoomEvent(type:String) {
		//public function ZoomEvent(type:String, zoom:String) {
			super(type, true);
			//_zoom = zoom;
		}
		
		public override function clone():Event {
			return new ZoomEvent(type);
			//return new ZoomEvent(type, _zoom);
		}

	}
	
}
