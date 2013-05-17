package odyssey
{
	import flash.display.MovieClip;
	
	// The rat MovieClip.
	public class DivingRatMVC extends red_dot{	
		
		private static var _totalRats:int = 0;	// how many rats have been made so far  		
		private var _id:Number;		// each rat has a unique ID#.
		
		public function DivingRatMVC(startingX:Number)
		{
			_id = _totalRats++;
			x = startingX;
		}
		
		public function get ID():int
		{		
			return _id;		
		}
		
		override public function toString():String
		{
			return "id:" + ID + " x:" + x + " y:" + y;
		}
	}
}