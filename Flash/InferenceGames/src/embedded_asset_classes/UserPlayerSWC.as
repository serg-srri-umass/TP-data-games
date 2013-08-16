// This is the player's icon and score bar.
// STRUCTURE: see PlayerAPI

// The user is the human playing the game. See also: BotPlayerSWC.

package embedded_asset_classes
{
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
	}
}