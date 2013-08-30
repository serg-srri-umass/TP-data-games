// This is the player's icon and score bar.
// STRUCTURE: see PlayerAPI

// The user is the human playing the game. See also: BotPlayerSWC.

package embedded_asset_classes
{
	import flash.events.Event;
	
	public class UserPlayerSWC extends playerSWC implements PlayerAPI
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static  var SINGLETON_PLAYER:UserPlayerSWC;
		
		public static function get PLAYER():UserPlayerSWC{
			return SINGLETON_PLAYER;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
				
		public function UserPlayerSWC()
		{
			super();
			if(!SINGLETON_PLAYER)
				SINGLETON_PLAYER = this;
			else
				throw new Error("PlayerSWC has already been created.");
		}
		
		public function hide( triggerEvent:Event = null):void{
			gotoAndPlay("hide");
		}
		
		public function show( triggerEvent:Event = null):void{
			gotoAndPlay("show");
		}
		
		// call this to earn a point for the UserPlayer.
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
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private var _score:int = 0;
	}
}