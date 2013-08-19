// This is the top bar, that animates data shooting into the graph.

/* STRUCTURE:
- this
	|- dataHolderMVC
		|- * (clips are attached here)
*/

package embedded_asset_classes
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class DataCannonSWC extends dataCannonSWC
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static  var SINGLETON_DATA_CANNON:DataCannonSWC;
		
		public static function get DATA_CANNON():DataCannonSWC{
			return SINGLETON_DATA_CANNON;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		public var dataTimer:Timer = new Timer(100, 0);
		
		// constructor
		public function DataCannonSWC()
		{
			super();
			
			if(!SINGLETON_DATA_CANNON)
				SINGLETON_DATA_CANNON = this;
			else
				throw new Error("DataCannonSWC has already been created.");
			
			dataTimer.addEventListener(TimerEvent.TIMER, fireData); // fire data at a rate specified by a timer. TO-DO: Make some variation.
			dataHolderMVC.addEventListener(AnimationEvent.UNLOAD, pushData); // when a data point finishes animating, push data to DG.
		}
		
		// starts firing the data cannon.
		public function startCannon():void{
			dataTimer.start();
		}
		
		// stops the data cannon and clears all data still in it.
		public function stopCannon():void{
			dataTimer.stop();
			DataPoint.removeAll();
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
	
		// fire a point of data down the data cannon.
		private function fireData(e:Event = null):void{
			var data:DataPointMVC = new DataPointMVC();
			dataHolderMVC.addChild(data);
			data.play();
		}
		
		// this method is called whenever a point of data is unloaded. Pushes the data to DG.
		private function pushData(e:Event = null):void{
			Round.currentRound.addData();
		}
	}
}