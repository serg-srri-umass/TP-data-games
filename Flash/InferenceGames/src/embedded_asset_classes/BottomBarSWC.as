// This is the bottom bar of the game. It says the name of the current level, 
// and has the controls for starting, and ending games. And starting new rounds.

/* STRUCTURE:
- this
	|- levelNameTxt
	|- nextRoundBtn
	|- newEndGameBtn [toggle button, with 3 looks "endGame" "startGame" "okay"]
	|
	|- gameOverMVC [labels: "hide", "isHidden", "show", "isShowing"]
		|- userBotMVC [labels: "user", "bot"] 
*/

package embedded_asset_classes
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class BottomBarSWC extends bottomBarSWC
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static  var SINGLETON_BOTTOM_BAR:BottomBarSWC;
		
		public static function get instance():BottomBarSWC{
			return SINGLETON_BOTTOM_BAR;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		public function BottomBarSWC()
		{
			super();
			if(!SINGLETON_BOTTOM_BAR)
				SINGLETON_BOTTOM_BAR = this;
			else
				throw new Error("BottomBarSWC has already been created.");
			
			disableNextRoundBtn(); // by default, the next round button is not visible. 
			newEndGameBtn.setClickFunctions(onPressEndGame, onPressNewGame, onPressEndGame);
			
			nextRoundBtn.addEventListener(MouseEvent.MOUSE_UP, onPressNextRoundBtn); // handler for when the next round button is clicked.
		}
		
		public function enableNextRoundBtn():void{
			nextRoundBtn.mouseEnabled = true;
			nextRoundBtn.addEventListener(Event.ENTER_FRAME, animateNextFrameBtn); // the next round button fades in.
		}
		
		public function disableNextRoundBtn():void{
			nextRoundBtn.mouseEnabled = false;
			nextRoundBtn.alpha = 0; // the next round button is made invisible instantly. 
		}
		
		// call this to put the bottom bar back to its original position. Used on endgame.
		public function reset():void{
			nextRoundBtn.removeEventListener( Event.ENTER_FRAME, animateNextFrameBtn);
			disableNextRoundBtn();
			if( gameOverMVC.visible)
				gameOverMVC.gotoAndPlay("hide");
		}
		
		// show the winner dialogue.
		public function showWinner( user:Boolean):void{
			gameOverMVC.visible = true;
			gameOverMVC.gotoAndPlay("show");
			var winnerLabel:String = user ? "user" : "bot";
			gameOverMVC.userBotMVC.gotoAndStop(winnerLabel);
			
			newEndGameBtn.look = 2;
		}
		
		// -------------------------
		// --- PRIVATE FUNCTIONS ---
		// -------------------------
		
		private function onPressNextRoundBtn( e:MouseEvent):void{
			disableNextRoundBtn();
			ResultsSWC.instance.hide(); 
			InferenceGames.instance.newRound();
		}
		
		// this method causes the "next round button" to fade in.
		private function animateNextFrameBtn( e:Event):void{
			if(nextRoundBtn.mouseEnabled){
				nextRoundBtn.alpha += 0.1;
				if(nextRoundBtn.alpha >= 1){
					nextRoundBtn.removeEventListener( Event.ENTER_FRAME, animateNextFrameBtn);
				}
			}
		}
		
		private function onPressEndGame( e:MouseEvent):void{
			newEndGameBtn.look = 1; // "new game"
			InferenceGames.instance.endGame();
			
		}
		
		private function onPressNewGame( e:MouseEvent):void{
			newEndGameBtn.look = 0; // "end game"
			LevelSelectSWC.instance.hide();
		}
	}
}