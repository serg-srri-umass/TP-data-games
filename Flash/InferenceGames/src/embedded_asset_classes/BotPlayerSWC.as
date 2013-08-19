// This is the expert's icon and score bar.
// STRUCTURE: see PlayerAPI

// The bot is the computer-controller player. See also: UserPlayerSWC.

package embedded_asset_classes
{
	public class BotPlayerSWC extends botSWC implements PlayerAPI
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static  var SINGLETON_BOT:BotPlayerSWC;
		
		public static function get BOT():BotPlayerSWC{
			return SINGLETON_BOT;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		public function BotPlayerSWC()
		{
			super();
			
			if(!SINGLETON_BOT)
				SINGLETON_BOT = this;
			else
				throw new Error("BotSWC has already been created.");
		}
		
		public function hide():void{
			gotoAndPlay("hide");
		}
		
		public function show():void{
			gotoAndPlay("show");
		}
	}
}