// this is an animating data point that shoots down the data cannon.
// when it collides with the cannon's wall, the DataPops class plays a pop, and the DataPoint restarts.

// used in DataCannon.swc

/* STRUCTURE:
	this
		|- * (DataPointPops are attached here)
	
	DataPointPop [labels: "hidden", "pop"]
*/

package  {
	import flash.display.MovieClip;
	
	public class DataPops  extends MovieClip{

		public function DataPops(){
			DataPoint.popMovieClip = this; // give the data movieclips a pointer to this.
		}
		
		// play a 'pop' on the screen, when a datapoint has hit the right wall.
		public function playPop( id:int):void{
			if(!popArray[id]){ // check if the pop movieclip already exists.
				popArray[id] = new DataPointPop(); // if it doesn't, create a new one.
				addChild(popArray[id]);
			}
			popArray[id].gotoAndPlay("pop"); // then make it play.
		}
		
		private var popArray:Array = new Array(); // all the DataPointPop objects that this MovieClip holds.
	}
	
}
