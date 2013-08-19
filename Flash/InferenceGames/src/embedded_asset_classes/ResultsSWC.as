// this MovieClip displays the results of a round.

/* STRUCTURE:
- this [labels: "hide", "show"]
	|- rangeMVC [labels: "user", "bot"]
	|	|-lowBoundTxt
	|	|-highBoundTxt
	|	
	|- accuracyMVC [labels: "user", "bot"]
	|	|- accuracyTxt
	|	|- shieldMVC [labels: "red", "yellow", "green"]
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
		
		public static function get RESULTS():ResultsSWC{
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
		}
		
		// starts the show animation, making this MovieClip visible.
		public function show( e:Event = null):void{
			visible = true;
			gotoAndPlay("show");
			
			setActivePlayer(Round.currentRound.lastBuzzer == UserPlayerSWC.PLAYER)
			setBounds( (Round.currentRound.guess - Round.currentRound.interval), (Round.currentRound.guess + Round.currentRound.interval));
			setAccuracy( Round.currentRound.accuracy);
		}
		
		// starts the hide animation. When it finishes, this MovieClip becomes invisible.
		public function hide( e:Event = null):void{
			gotoAndPlay("hide");
			BotPlayerSWC.BOT.show();
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private function onCompleteHide( triggerEvent:AnimationEvent):void{
			visible = false;
			ControlsSWC.CONTROLS.show();
		}
		
		private function onCompleteShow( triggerEvent:AnimationEvent):void{
			BottomBarSWC.BOTTOM_BAR.enableNextRoundBtn(); 
			Round.currentRound.lastBuzzer.earnPoint();		// the last player to buzz in earns a point. TO-DO: add the miss-hit functionality.
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
			
			if(accuracy > 75)
				accuracyMVC.shieldMVC.gotoAndStop("green");
			else if(accuracy > 50)
				accuracyMVC.shieldMVC.gotoAndStop("yellow");
			else
				accuracyMVC.shieldMVC.gotoAndStop("red");
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