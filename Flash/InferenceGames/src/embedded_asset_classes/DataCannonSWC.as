// This is the top bar, that animates data shooting into the graph.

/* STRUCTURE:
- this
	|- dataHolderMVC
	|	|- dataHolderMVC
	|	|	|- (10 Unnamed DataPoints)
	|	|	|- catcher:DataPops
	|	|		|- * (DataPointPops attached here)
	|	|
	|	|- speedMVC (labels: "up", "over")
	|
	|- dragAreaBtn
			|- speedLabelMVC
				|- speedTxt
*/

package embedded_asset_classes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	//import flash.display.Stage;

	public class DataCannonSWC extends dataCannonSWC
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static const kPadding:int = 20; // how many px padding are on each side of the data cannon.
		private static  var SINGLETON_DATA_CANNON:DataCannonSWC;
		
		public static function get DATA_CANNON():DataCannonSWC{
			return SINGLETON_DATA_CANNON;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		
		// constructor
		public function DataCannonSWC()
		{
			super();
			
			if(!SINGLETON_DATA_CANNON)
				SINGLETON_DATA_CANNON = this;
			else
				throw new Error("DataCannonSWC has already been created.");
			
			// establish the draggable rectangle.
			mDragBounds = new Rectangle(kPadding, 0, dragAreaBtn.width - speedMVC.width - (kPadding * 2), 0); // 20px padding on the left and right. TO-DO: Needs adjusting so % can get to 1 and 100.
			
			// mouse events for dragging the slider:
			dragAreaBtn.addEventListener(MouseEvent.MOUSE_DOWN, startDragMVC);
			dragAreaBtn.addEventListener(MouseEvent.MOUSE_OVER, handleOverSpeed);
			dragAreaBtn.addEventListener(MouseEvent.MOUSE_OUT, handleUpSpeed);
			InferenceGames.stage.addEventListener(MouseEvent.MOUSE_UP, stopDragMVC);
			//To-Do: lose focus code, taken from Ship Odyssey.
			
			addEventListener(AnimationEvent.PUSH_DATA, pushData);
			
			calculateSpeedPercent(); // calculate the speed on load.
		}
		
		// start firing the data cannon, in bursts of 10.
		public function startCannon():void{
			DataPoint.start();
			DataPoint.paused = false;
		}
		
		// stop firing the cannon, and clear out all data points currently in it.
		public function stopCannon():void{
			DataPoint.stop();
			DataPoint.paused = true;
		}
		
		public function pauseCannon():void{
		}
		
		// set the cannon's speed, based on a percent.
		public function set speed( percent:Number):void{
			if(percent <= 0 || percent > 1)
				throw new Error(" Speed percent must range from >0 to 1");
			
			mSpeedPercent = percent;
			DataPoint.setSpeed(mSpeedPercent);
			speedMVC.x = calculateSpeedHandleX();
			
			var speedInt:int = mSpeedPercent * 100;
			dragAreaBtn.speedLabelMVC.speedTxt.text = speedInt + "%";
		}
		
		// returns the speed as a number from 0 to 1.
		public function get speed():Number{
			return mSpeedPercent;
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private var mIsDragging:Boolean = false; // is the mouse dragging the slider?
		private var mIsMouseOver:Boolean = false; // is the mouse over the drag-box?
		private var mDragBounds:Rectangle; // the range in which the speedMVC can be dragged
		private var mSpeedPercent:Number; // the % the speed bar is at.
		
		// start dragging the slider.
		private function startDragMVC( triggerEvent:Event):void{
			InferenceGames.stage.addEventListener(MouseEvent.MOUSE_MOVE, calculateSpeedPercent);
			speedMVC.startDrag(true, mDragBounds);
			mIsDragging = true;
		}
		
		// stop dragging the slider.
		private function stopDragMVC( triggerEvent:Event):void{
			InferenceGames.stage.removeEventListener(MouseEvent.MOUSE_MOVE, calculateSpeedPercent);
			speedMVC.stopDrag();
			mIsDragging = false;
			if(!mIsMouseOver){
				speedMVC.gotoAndStop("up");
				dragAreaBtn.gotoAndStop(1);
			}
			calculateSpeedPercent(); // when the user stops dragging, update the speed for safety.
		}
		
		// make the speedMVC go to its 'over' state.
		private function handleOverSpeed( triggerEvent:Event):void{
			speedMVC.gotoAndStop("over");
			dragAreaBtn.gotoAndStop(2);
			mIsMouseOver = true;
		}
		
		// make the speedMVC go to its 'up' state.
		private function handleUpSpeed( triggerEvent:Event):void{
			mIsMouseOver = false;
			if(!mIsDragging){
				speedMVC.gotoAndStop("up");
				dragAreaBtn.gotoAndStop(1);
			}
		}
		
		// calculate the speed, based on the position of the dragging slider.
		private function calculateSpeedPercent( triggerEvent:Event = null):void{
			mSpeedPercent = speedMVC.x / dragAreaBtn.width; // x value should go from 0 to the width of the container
			DataPoint.setSpeed(mSpeedPercent);
			
			var speedInt:int = mSpeedPercent * 100;
			dragAreaBtn.speedLabelMVC.speedTxt.text = speedInt + "%";
		}
		
		// when setting the speed % automatically, use this to determine the speedMVC's x position.
		private function calculateSpeedHandleX():Number{
			return dragAreaBtn.width * mSpeedPercent;
		}
		
		// this method is called whenever a point of data is unloaded. Pushes the data to DG.
		private function pushData( triggerEvent:Event = null):void{
			Round.currentRound.addData();
		}
	}
}