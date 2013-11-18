package  {
	import flash.events.Event;
	
	public class InferenceEvent extends Event{
		
		public static const ENTER_GUESS_MODE:String = "egm";
		public static const ENTER_MOUSE_MODE:String = "emm";
		
		public static const SAMPLE:String = "sample";
		public static const OVERDRAW:String = "overdraw";
		
		public static const CORRECT_GUESS:String = "cguess";
		public static const INCORRECT_GUESS:String = "iguess";
		
		public static const LOSE_LIFE:String = "lose_health";
		public static const EARN_POINT:String = "earn_points";
		
		public function InferenceEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ){
			// constructor code
			super( type, bubbles, cancelable);
		}

	}
	
}
