// this is an animating data point that shoots down the data cannon.
// when it finishes animating, it unloads itself and dispatches an event.

// used in DataCannon.swc

/* STRUCTURE:
	this
	|- dot (call dot.play() and this.stop() to unload this dataPoint)
*/

package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class DataPoint extends MovieClip
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		// this vector holds all currently active data points.
		private static const DATA_VECTOR:Vector.<DataPoint> = new Vector.<DataPoint>(); 
		
		// stops all currently active data points.
		public static function stopAll():void{
			for(var i:int = 0; i < DATA_VECTOR.length; i++)
				DATA_VECTOR[i].stop();
		}
		
		// play all currently active data points.
		public static function playAll():void{
			for(var i:int = 0; i < DATA_VECTOR.length; i++)
				DATA_VECTOR[i].play();
		}
		
		// remove all currently active data points.
		public static function removeAll():void{
			while(DATA_VECTOR.length){
				var currentData:DataPoint = DATA_VECTOR.pop();
				currentData.stop();
				currentData.dot.play(); // makes the dot appear to 'self destruct'.
			}
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		// constructor
		public function DataPoint()
		{
			super();
			DATA_VECTOR.push(this);
		}
		
		// this method is called from the dataPoint when it reaches its last frame.
		public function finish():void{
			stop();
			parent.dispatchEvent(new Event(AnimationEvent.UNLOAD));
			parent.removeChild(this); // remove the data point from the screen.
			
			// remove this data point from the vector of live data points.
			for(var i:int = 0; i < DATA_VECTOR.length; i++){
				DATA_VECTOR.splice(i, 1);
				break;
			}
		}
	}
}