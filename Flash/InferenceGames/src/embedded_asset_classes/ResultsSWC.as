// this MovieClip displays the results of a round.

/* STRUCTURE:
- this [labels: "hide", "show"]
	|- rangeMVC [labels: "user", "bot"]
	|	|-lowBoundTxt
	|	|-highBoundTxt
	|	
	|- accuracyMVC [labels: "user", "bot"]
	|	|- accuracyTxt
	|
	|- verdictMVC [labels: "user", "bot"]
		|- winLoseMVC [labels: "win", "lose"]
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
		public function show( e:Event = null):void{
			visible = true;
			gotoAndPlay("show");
			
			setActivePlayer(Round.currentRound.lastBuzzer == UserPlayerSWC.instance)
			setBounds( (Round.currentRound.guess - Round.currentRound.interval), (Round.currentRound.guess + Round.currentRound.interval));
			setAccuracy( Round.currentRound.accuracy);
			this.setWon(Round.currentRound.isWon);
			Round.currentRound.lastBuzzer.emotion = Round.currentRound.isWon ? BotPlayerSWC.HAPPY : BotPlayerSWC.SAD;

			_isShowing = true;
		}
		
		// starts the hide animation. When it finishes, this MovieClip becomes invisible.
		public function hide( e:Event = null):void{
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
				InferenceGames.instance.winGame(true);
			else if( BotPlayerSWC.instance.score >= Round.WINNING_SCORE)
				InferenceGames.instance.winGame(false);
			else
				BottomBarSWC.instance.enableNextRoundBtn();
		}
		
		// sets which player buzzed in: either the user or the bot. 
		// this method must be called BEFORE the other setters!
		public function setActivePlayer( user:Boolean):void{
			if( user){
				rangeMVC.gotoAndStop("user");
				accuracyMVC.gotoAndStop("user");
				verdictMVC.gotoAndStop("user");
			} else {
				rangeMVC.gotoAndStop("bot");
				accuracyMVC.gotoAndStop("bot");
				verdictMVC.gotoAndStop("bot");
			}
		}
		
		// sets the low and high bound of the range, in the display
		public function setBounds( lowBound:Number, highBound:Number):void{
			rangeMVC.lowBoundTxt.text = lowBound.toFixed(1);
			rangeMVC.highBoundTxt.text = highBound.toFixed(1);
			rangeMVC.lowBoundTxt.setTextFormat(TextFormatter.BOLD);
			rangeMVC.highBoundTxt.setTextFormat(TextFormatter.BOLD);
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
			if(won)
				verdictMVC.winLoseMVC.gotoAndStop("win");
			else
				verdictMVC.winLoseMVC.gotoAndStop("lose");
		}
	}
}