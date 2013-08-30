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
		
		private static  var SINGLETON_BOT:BotPlayerSWC;
		
		public static function get BOT():BotPlayerSWC{
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
		}
		
		public function hide( triggerEvent:Event = null):void{
			gotoAndPlay("hide");
		}
		
		public function show( triggerEvent:Event = null):void{
			gotoAndPlay("show");
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
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private var _score:int = 0;
	}
}