// This MovieClip is the main game control. 
// It has the "Stop" button, the current average of the data,
// and the two "Shields" that display this round's
// interval and standard deviation.

/* STRUCTURE:
- this [labels: "hide", "show"]
	|- stopControlsMVC
	|	|- stopStartBtn	[labels: "ready", "user", "bot"]
	|	|	|- pauseBtn [looks: stop(0), start(1)]
	|	|
	|	|- currentSampleMedianMVC
	|		|- currentSampleMedianTxt
	|	
	|- shieldsMVC
		|- intervalMVC [labels: "singleDigit", "doubleDigit"]
		|	|- intervalTxt
		|
		|- deviationMVC
			|- deviationTxt
*/

package embedded_asset_classes
{
	import common.TextFormatter;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ControlsSWC extends controlsSWC implements ShowHideAPI
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static var SINGLETON_CONTROLS:ControlsSWC;
		
		public static function get CONTROLS():controlsSWC{
			return SINGLETON_CONTROLS;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
				
		// constructor
		public function ControlsSWC(){
			super();
			if(!SINGLETON_CONTROLS)
				SINGLETON_CONTROLS = this;
			else
				throw new Error("ControlsSWC has already been created.");
			
			visible = false;
			addEventListener(AnimationEvent.COMPLETE_HIDE, onCompleteHide); // handler for when hide animation is complete.
			stopControlsMVC.stopStartBtn.pauseBtn.setClickFunctions(stopFunction, startFunction); // the stop/start button uses these methods on click.
			stop();
		}
		
		// starts the show animation, making this MovieClip visible.
		public function show( triggerEvent:Event = null):void{
			visible = true;
			stopControlsMVC.stopStartBtn.pauseBtn.look = 1; // set the button to 'start'
			stopControlsMVC.stopStartBtn.gotoAndStop( "ready");
			gotoAndPlay("show");
			_isShowing = true;
		}
		
		// starts the hide animation. When it finishes, this MovieClip becomes invisible.
		public function hide( triggerEvent:Event = null):void{
			gotoAndPlay("hide");
			_isShowing = false;
		}
				
		// sets the text on the IQR shield.
		// note: this is just a display. Changing this does not change the calculations.
		public function set IQR( param_iqr:Number):void{
			shieldsMVC.deviationMVC.deviationTxt.text = param_iqr.toFixed(0);
			shieldsMVC.deviationMVC.deviationTxt.setTextFormat(TextFormatter.BOLD);
		}
		
		// sets the text on the interval shield.
		// note: this is just a display. Changing this does not change the calculations.
		public function set interval( param_interval:Number):void{
			shieldsMVC.intervalMVC.intervalTxt.text = param_interval.toFixed(0);
			shieldsMVC.intervalMVC.intervalTxt.setTextFormat(TextFormatter.BOLD);
			
			if(param_interval >= 10) // bump over the +- sign if the interval is 2 digits.
				shieldsMVC.intervalMVC.gotoAndStop("doubleDigit");
			else
				shieldsMVC.intervalMVC.gotoAndStop("singleDigit");
		}
		
		public function get isShowing():Boolean{
			return _isShowing;
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private var _isShowing:Boolean = false;
		
		// this method is called when the player hits the stop button. 
		private function stopFunction( e:MouseEvent):void{
			InferenceGames.instance.hitBuzzer();
		}
		
		// called when the player hits the start button.
		private function startFunction( e:MouseEvent):void{
			stopControlsMVC.stopStartBtn.pauseBtn.look = 0;
			DataCannonSWC.DATA_CANNON.startCannon();			
		}
		
		// when the ControlsSWC finishes hiding itself, this method is called. It turns on the results.
		private function onCompleteHide( e:AnimationEvent):void{
			visible = false;
			if(InferenceGames.instance.isInGame)
				ResultsSWC.RESULTS.show();
		}
		
	}
}