// This is the top bar, that animates data shooting into the graph.

/* STRUCTURE:
- this
	|- dataCannonMVC
		|- * (clips are attached here)
*/

package embedded_asset_classes
{
	public class DataCannonSWC extends dataCannonSWC
	{
		// ----------------------
		// --- STATIC SECTION ---
		// ----------------------
		
		private static  var SINGLETON_DATA_CANNON:DataCannonSWC;
		
		public static function get BOTTOM_BAR():DataCannonSWC{
			return SINGLETON_DATA_CANNON;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		public function DataCannonSWC()
		{
			super();
			
			if(!SINGLETON_DATA_CANNON)
				SINGLETON_DATA_CANNON = this;
			else
				throw new Error("DataCannonSWC has already been created.");
		}
	}
}