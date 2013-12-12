package commonSWFClasses
{
	// This class represents a single button that has multiple looks. For example, a "Pause/Play" button.
	// Each look can have a seperate method assigned to it.
	// For a movieclip to be a ToggleButton, each look must have a group of three frames representing it. (UP, OVER and DOWN. These need to be in order, but not necessarily labeled). 
	// ToggleButtons cannot have any additional frames.
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class ToggleButton extends MovieClip
	{
		private const UP:uint = 1, OVER:uint = 2, DOWN:uint = 3; // constants representing the state of the current button.
		
		private var _numLooks:uint;		// how many states this button has. 
		private var _look:uint = 0; 	// which state the button is currently in. Each look is represented by a number, index 0. 
		private var functionVector:Vector.<Function> = new Vector.<Function>(); // this array holds the button's functions in all of its states.
		
		public function ToggleButton(){
			super();
			
			// ensure that the ToggleButton has the proper number of frames:
			if(this.totalFrames % 3 == 0)
				_numLooks = this.totalFrames/3;
			else
				throw new Error( "ToggleButtons must have exactly 3 frames per Look. For details, view ToggleButton.as"); 
			
			super.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
			super.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			super.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			super.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			this.buttonMode = true;
			
			for( var i:int = 0; i < numLooks; i++)
				functionVector.push( blankFunction);
		}
		
		// ======================
		// === PUBLIC METHODS ===
		// ======================
		
		// Each look is represented by a number, index 0. 
		public function get look():int{
			return _look;
		}
		
		// set the look of the button.
		public function set look( arg:int):void{
			if( arg < 0 || arg >= _numLooks)
				throw new Error( "Invalid look. " + this.toString() + " has " + numLooks + " looks."); 
			
			var moveDist:int = currentFrame - (look * 3);
			_look = arg;
			gotoAndStop(moveDist + (look * 3));
		}
		
		public function get numLooks():int{
			return _numLooks;
		}
		
		// use this function to set what the button does when clicked in each of its looks. Define a method for each of the buttons states.
		// pass this one function per look. 
		// for example, a play-pause button would have setClickFunctions(playFunction, pauseFunction);
		public function setClickFunctions( ...rest):void{
			if(rest.length != numLooks)
				throw new Error("A method must be provided for each of this button's looks. " + this.toString() + " has " + numLooks + " looks."); 
			
			for( var i:int = 0; i < rest.length; i++){
				functionVector[i] = rest[i];
			}
		}
		
		// ==========================
		// === OVERRIDDEN METHODS ===
		// ==========================
		
		// this function is overridden because ToggleButtons aren't allowed to have MouseClicks, MouseDowns, MouseUps assigned to them. It would
		// interfere with each look having a seperate click method.
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			switch(type){
				case MouseEvent.CLICK:
				case MouseEvent.MOUSE_DOWN:
				case MouseEvent.MOUSE_UP:
					throw new Error("This event listener is reserved by the StateButton class. For details, view StateButton.as");
					break;
				default:
					super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		
		// set whether the ToggleButton is enabled.
		override public function set enabled(value:Boolean):void{
			super.enabled = value;
			mouseEnabled = value;
		}
		
		// =======================
		// === PRIVATE METHODS ===
		// =======================
		
		// these functions simulate the workings of a SimpleButton.		
		private function handleMouseOver( e:MouseEvent):void{
			this.gotoAndStop( OVER + ( look * 3) );
		}
		
		private function handleMouseOut( e:MouseEvent):void{
			this.gotoAndStop( UP + ( look * 3) );
		}
		
		private function handleMouseDown( e:MouseEvent):void{
			this.gotoAndStop( DOWN + ( look * 3) );
		}
		
		// when the mouse is released on this button, perform the appropriate function.
		private function handleMouseUp( e:MouseEvent):void{
			var performFunction:Function = functionVector[look];
			performFunction( new MouseEvent(MouseEvent.MOUSE_UP ));
			
			this.gotoAndStop( OVER + ( look * 3) );
		}
		
		// this function is used on looks with no method assigned to them.
		private function blankFunction( e:* = null):void{}
	}
}