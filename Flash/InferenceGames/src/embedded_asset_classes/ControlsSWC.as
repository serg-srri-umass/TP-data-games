// This MovieClip is the main game control. 
// It has the "Stop" button, the current average of the data,
// and the two "Shields" that display this round's
// interval and standard deviation.

/* STRUCTURE:
- this [labels: "hide", "show"]
	|- stopControlsMVC
	|	|- stopStartBtn	[labels: "ready", "user", "bot"]
	|	|	|- pauseBtn [looks: stop(0), start(1)]
	|	|		*this is currently a simplebutton. it should be made into a togglebutton.
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
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class ControlsSWC extends controlsSWC
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
			stopControlsMVC.stopStartBtn.pauseBtn.addEventListener(MouseEvent.CLICK, stopFunction); // handler for when 'stop' button is clicked.
		}
		
		// starts the show animation, making this MovieClip visible.
		public function show( e:Event = null):void{
			visible = true;
			stopControlsMVC.stopStartBtn.gotoAndStop( "ready");
			gotoAndPlay("show");
		}
		
		// starts the hide animation. When it finishes, this MovieClip becomes invisible.
		public function hide( e:Event = null):void{
			gotoAndPlay("hide");
		}
		
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		// this method is called when the player hits the stop button. 
		private function stopFunction( e:MouseEvent):void{
			hide();
			stopControlsMVC.stopStartBtn.gotoAndStop( "player");
		}
		
		// when the ControlsSWC finishes hiding itself, this method is called. It turns on the results.
		private function onCompleteHide( e:AnimationEvent):void{
			visible = false;
			ResultsSWC.RESULTS.show(); // TO-DO: Move this to the main. 
		}
		
	}
}