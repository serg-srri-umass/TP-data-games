// this MovieClip displays the results of a round.

/* STRUCTURE:
- this [labels: "hide", "show"]
	|- accuracyMVC [labels: "user", "bot"]
	|	|- accuracyTxt
	|
	|- verdictMVC [labels: "user", "bot"]
		|- winLoseMVC [labels: "win", "lose"]
			|- popMedianMVC
				|- medianTxt
*/

package embedded_asset_classes
{
	import common.TextFormatter;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ResultsSWC extends resultsSWC implements ShowHideAPI
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static var SINGLETON_RESULTS:ResultsSWC;
		
		public static function get instance():ResultsSWC{
			return SINGLETON_RESULTS;
		}

		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
			
		public function ResultsSWC()
		{
			super();
			if(!SINGLETON_RESULTS)
				SINGLETON_RESULTS = this;
			else
				throw new Error("ResultsSWC has already been created.");

			addEventListener(AnimationEvent.COMPLETE_HIDE, onCompleteHide); // handler for when hide animation is complete.
			addEventListener(AnimationEvent.COMPLETE_SHOW, onCompleteShow); // handler for when the show animation is complete.
			visible = false;
			stop();
		}
		
		// starts the show animation, making this MovieClip visible.
		public function show( triggerEvent:* = null):void{
			visible = true;
			gotoAndPlay("show");
			
			setActivePlayer(Round.currentRound.lastBuzzer == UserPlayerSWC.instance)
			setAccuracy( Round.currentRound.accuracy);			
			this.setWon(Round.currentRound.isWon);
			Round.currentRound.lastBuzzer.emotion = Round.currentRound.isWon ? BotPlayerSWC.HAPPY : BotPlayerSWC.SAD;

			_isShowing = true;
		}
		
		// starts the hide animation. When it finishes, this MovieClip becomes invisible.
		public function hide( triggerEvent:* = null):void{
			gotoAndPlay("hide");
			_isShowing = false;
		}
		
		public function get isShowing():Boolean{
			return _isShowing;
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		private var _isShowing:Boolean = false;
		
		private function onCompleteHide( triggerEvent:AnimationEvent):void{
			visible = false;
			if(InferenceGames.instance.isInGame)
				ControlsSWC.instance.show();
				else 
				LevelSelectSWC.instance.show();
		}

		// when the results finish displaying, if the game is over, show the winner.
		private function onCompleteShow( triggerEvent:AnimationEvent):void{
			Round.currentRound.handlePoints(); // update points for this game
			InferenceGames.instance.closeRoundData(); // show final round data in DG
			
			if( UserPlayerSWC.instance.score >= Round.WINNING_SCORE)
				InferenceGames.instance.winLoseGame(true);
			else if( BotPlayerSWC.instance.score >= Round.WINNING_SCORE)
				InferenceGames.instance.winLoseGame(false);
			else
				BottomBarSWC.instance.enableNextRoundBtn();
		}
		
		// sets which player buzzed in: either the user or the bot. 
		// this method must be called BEFORE the other setters!
		public function setActivePlayer( user:Boolean):void{
			if(user){
				accuracyMVC.gotoAndStop("user");
				verdictMVC.gotoAndStop("user");
			} else {
				accuracyMVC.gotoAndStop("bot");
				verdictMVC.gotoAndStop("bot");
			}
		}
		
		// sets the accuracy shield
		public function setAccuracy( accuracy:int):void{
			if( accuracy < 0 || accuracy > 100)
				throw new Error("Accuracy must be a percent.");
			
			accuracyMVC.accuracyTxt.text = accuracy;
			accuracyMVC.accuracyTxt.setTextFormat(TextFormatter.BOLD);
		}
		
		// set the win/lose screen
		public function setWon( won:Boolean):void{
			var winLoseString:String = won ? "win" : "lose";
			verdictMVC.winLoseMVC.gotoAndStop(winLoseString);
			
			if( !ControlsSWC.instance.DEBUG_autoGuess){
				verdictMVC.winLoseMVC.popMedianMVC.medianTxt.text = Round.currentRound.populationMedian.toFixed(1);
				verdictMVC.winLoseMVC.popMedianMVC.visible = true;
			} else {
				verdictMVC.winLoseMVC.popMedianMVC.visible = false;
			}
		}
	}
}