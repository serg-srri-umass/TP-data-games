// this is an animating data point that shoots down the data cannon.
// when it collides with the cannon's wall, the DataPops class plays a pop, and the DataPoint restarts.

// used in DataCannon.swc

/* STRUCTURE:
	this [labels: "isShowing", "hide"]
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
		private static const CANNON_WIDTH:Number = 555; // how wide the cannon movieclip is. 
		private static const FASTEST_SPEED:Number = 50; // the fastest a data point can travel in px/frame.		
		private static const PADDING:Number = 50;	// how many px each DataPoint starts apart.
		
		private static var _numDataPoints:int = 0; // how many DataPoints are on-screen.
		private static var _paused:Boolean = false; // cannon is paused?
		private static var _speed:Number = FASTEST_SPEED; // the speed that all data points travel at.
		private static var _popMovieClip:DataPops; // the movieclip that plays 'popping' animations when datapoints hit the edge of the cannon.
		private static var _dataPointVector:Vector.<DataPoint> = new Vector.<DataPoint>();
		
		// sets the speed of data being fired out of the cannon.
		public static function setSpeed( percent:Number):void{
			_speed = FASTEST_SPEED * percent;
		}
		
		// stops/plays all currently active data points.
		public static function set paused( arg:Boolean):void{
			_paused = arg;
		}
		
		public static function get paused():Boolean{
			return _paused;
		}
		
		// restarts the data cannon's firing.
		public static function start():void{
			for( var i:int = 0; i < _dataPointVector.length; i++){
				_dataPointVector[i].live = true;
				_dataPointVector[i].gotoAndStop("isShowing");
				_dataPointVector[i].x = -1 * _dataPointVector[i].serialNumber * PADDING;	
			}
		}
		
		// remove all currently active data points.
		public static function stop():void{
			for( var i:int = 0; i < _dataPointVector.length; i++){
				_dataPointVector[i].live = false;
				_dataPointVector[i].gotoAndPlay("hide");
			}
		}
		
		// set which movieclip will house the 'pop's that play when data hits the edge of the cannon.
		public static function set popMovieClip( movie:DataPops):void{
			if(_popMovieClip) 
				throw new Error("popMovieClip has already been set.");
			_popMovieClip = movie;
		}
		
		// ----------------------
		// --- PUBLIC SECTION ---
		// ----------------------
		
		// constructor
		public function DataPoint()
		{
			super();
			stop();
			
			serialNumber = _numDataPoints++;
			x = padding = -1 * serialNumber * PADDING;			
			
			_dataPointVector.push(this);
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		// -----------------------
		// --- PRIVATE SECTION ---
		// -----------------------
		
		private var serialNumber:int; // each data point on screen has a serial number.
		private var padding:int; // how many pixels back this DataPoint will load in the cannon when the firing starts.
								 // delay is based on how many other DataPoints exist. 
		private var live:Boolean = false; // this boolean represents whether the datapoint has hit the wall this round.
		
		// called every frame. advances the X position of this dot, and if it hits the wall, animates it forward.
		private function handleEnterFrame( e:Event = null):void{
			if( !_paused && live){
				x += _speed;
				if(x >= CANNON_WIDTH) // the datapoint has hit the wall of the cannon.
					collide(); 
			}
		}
		
		// called when a datapoint hits the wall of the cannon.
		private function collide():void{
			x = padding;	
			live = false;
			_popMovieClip.playPop( serialNumber);
			dispatchEvent(new AnimationEvent(AnimationEvent.PUSH_DATA, true) );
			
			// when all the data points of the last round have finished animating, this function starts a new round.
			if(serialNumber == _numDataPoints - 1){
				for( var i:int = 0; i < _dataPointVector.length; i++){
					_dataPointVector[i].live = true;
					x = padding;	
				}
			}
		}
		
		// this method is called from the dataPoint when it reaches its last frame.
		/*public function finish():void{
			stop();
			parent.dispatchEvent(new Event(AnimationEvent.UNLOAD));
			parent.removeChild(this); // remove the data point from the screen.
			
			// remove this data point from the vector of live data points.
			for(var i:int = 0; i < DATA_VECTOR.length; i++){
				DATA_VECTOR.splice(i, 1);
				break;
			}
		}*/
	}
}