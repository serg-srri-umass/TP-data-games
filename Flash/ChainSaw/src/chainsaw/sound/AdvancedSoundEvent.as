package chainsaw.sound{
	import flash.events.Event;
	
	public class AdvancedSoundEvent extends Event{
		
		public static const FADED_IN:String = "fadedIn";
		public static const FADED_OUT:String = "fadedOut";
		
		//default event constructor
		public function AdvancedSoundEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
	}
}