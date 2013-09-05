// this class simulates the functionality of a simplebutton using a movieclip. Useful for buttons that need more than 3 frames.
// example: a checkbox needs a 4th "checked" frame.

package
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class MovieClipButton extends MovieClip
	{
		
		// ======================
		// === PUBLIC METHODS ===
		// ======================
		
		public function MovieClipButton()
		{
			super();
			super.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
			super.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			super.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			super.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			this.buttonMode = true; // gives you a hand cursor when you mouse over this object.
			
			stop();
		}
		
		// =======================
		// === PRIVATE METHODS ===
		// =======================
		
		protected const UP:uint = 1, OVER:uint = 2, DOWN:uint = 3; // constants representing the state of the current button.
		
		private function handleMouseOver( e:MouseEvent):void{
			if(enabled)
				this.gotoAndStop( OVER );
		}
		
		private function handleMouseOut( e:MouseEvent):void{
			if(enabled)
				this.gotoAndStop( UP  );
		}
		
		private function handleMouseDown( e:MouseEvent):void{
			if(enabled)
				this.gotoAndStop( DOWN  );
		}
		
		// when the mouse is released on this button, perform the appropriate function.
		private function handleMouseUp( e:MouseEvent):void{			
			if(enabled)
				this.gotoAndStop( OVER );
		}
	}
}