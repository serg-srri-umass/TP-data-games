package embedded_asset_classes  {
	import flash.events.Event;
	
	public class InferenceEvent extends Event{
		
		public static const REQUEST_SAMPLE:String = "req_sample";
		public static const REQUEST_NEW_ROUND:String = "req_new_round";
		public static const REQUEST_NEW_GAME:String = "req_new_game";
		public static const REQUEST_CHANGE_LEVEL:String = "req_cl";
		
		public static const REQUEST_GUESS_MODE_RED:String = "egm";
		public static const REQUEST_GUESS_MODE_GREEN:String = "egmg";
		
		public static const SAMPLE:String = "sample";
		public static const CORRECT_GUESS:String = "cguess";
		public static const INCORRECT_GUESS:String = "iguess";
			
		public static const LOSE_GAME:String = "loseGame";
		public static const WIN_GAME:String = "winGame";
		
		public static const EXPERT_START_TURN:String = "startexpertturn";
		public static const EXPERT_START_TYPING:String = "startexperttyping";
		
		
		public function InferenceEvent( type:String, bubbles:Boolean = true, cancelable:Boolean = false ){
			// constructor code
			super( type, bubbles, cancelable);
		}

	}
	
}
