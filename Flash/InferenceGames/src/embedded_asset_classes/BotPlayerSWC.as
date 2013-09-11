// This is the expert's icon and score bar.
// STRUCTURE: see PlayerAPI

// The bot is the computer-controller player. See also: UserPlayerSWC.

package embedded_asset_classes
{
	import flash.events.Event;

	public class BotPlayerSWC extends botSWC implements PlayerAPI
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		public static const NEUTRAL:String = "neutral";
		public static const HAPPY:String = "happy";
		public static const SAD:String = "sad";
		private static  var SINGLETON_BOT:BotPlayerSWC;
		
		public static function get instance():BotPlayerSWC{
			return SINGLETON_BOT;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		// constructor
		public function BotPlayerSWC()
		{
			super();
			
			if(!SINGLETON_BOT)
				SINGLETON_BOT = this;
			else
				throw new Error("BotSWC has already been created.");
			
			gotoAndStop("isHidden");
			avatarMVC.stop();
		}
		
		public function hide( triggerEvent:* = null):void{
			gotoAndPlay("hide");
			_isShowing = false;
		}
		
		public function show( triggerEvent:* = null):void{
			gotoAndPlay("show");
			_isShowing = true;
		}
		
		// call this to earn a point for the BotPlayer.
		public function earnPoint():void{
			_score++;
			if(_score <= Round.WINNING_SCORE){
				scoreMVC["point" + _score + "MVC"].gotoAndPlay("show");
				scoreMVC.capMVC.gotoAndStop(_score + 1);
			}
		}
				
		public function get score():int{
			return _score;
		}
		
		public function get otherPlayer():PlayerAPI{
			return UserPlayerSWC.instance;
		}
		
		public function get isShowing():Boolean{
			return _isShowing;
		}
		
		// resets the score bar to its starting position. Called on endGame.
		public function reset():void{
			var clearingScore:int = score < 6 ? score : 6;
			for( var i:int = 1; i <= clearingScore; i++){
				if(scoreMVC["point" + i + "MVC"])
					scoreMVC["point" + i + "MVC"].gotoAndPlay("hide");
			}
			scoreMVC.capMVC.gotoAndStop(1);
			_score = 0;
		}

		// set the avatar drawing's face, based on whether he/she guessed correctly or incorrectly.
		public function set emotion(emotion:String):void{
			if(emotion != NEUTRAL && emotion != HAPPY && emotion != SAD)
				throw new Error("invalid emotion. Please use NEUTRAL, HAPPY, or SAD");
			if(_currentEmotion != NEUTRAL && emotion != NEUTRAL)
				throw new Error("face must be NEUTRAL to set this emotion.");
			
			if(emotion != _currentEmotion){
				avatarMVC.gotoAndPlay ( _currentEmotion + "_to_" + emotion);
				_currentEmotion = emotion;
			}
		}
		
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		private var _isShowing:Boolean = false;
		private var _score:int = 0;
		private var _currentEmotion:String = NEUTRAL;
	}
}