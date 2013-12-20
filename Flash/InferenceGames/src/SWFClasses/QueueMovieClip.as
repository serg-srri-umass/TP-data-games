// A QUEUE MOVIECLIP HAS A SPECIAL FUNCTION 'gotoQueuedFrame', that can be placed in its timeline.
// when this command executes, if a queuedFrame has been set, it will gotoAndPlay that frame.
// otherwise, it will stop.

// this is useful for MVC's which chain multiple animations together

package {
	import flash.display.MovieClip;
	
	public class QueueMovieClip extends MovieClip {
		
		private var _queueFunc:Function;
		
		public function QueueMovieClip() {
			// constructor code
		}
		
		
		public function set queueFunction( func:Function):void{
			_queueFunc = func;
		}
		
		public function get queueFunction():Function{
			return _queueFunc;
		}
		
		public function gotoQueuedFrame():Boolean{
			if( _queueFunc != null){
				stop();
				_queueFunc();
				_queueFunc = null;
				return true;
			} else {
				stop();	// if nothing is queued, stop the playhead.
				return false;
			}
		}
	}
	
}
