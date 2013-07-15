package common{
	import flash.events.Event;
	
	public class AdvancedSoundEvent extends Event{
		
		public static const FULL_VOL:String = "fullVol";
		
		//default event constructor
		public function AdvancedSoundEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
	}
}