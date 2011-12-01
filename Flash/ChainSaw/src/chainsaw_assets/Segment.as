package chainsaw_assets  
{
	import flash.geom.Point;
	
	/**
	 * Line/curve geometry and helpers
	 * @author Philippe / http://philippe.elsass.me
	 */
	public class Segment 
	{
		public var start:Point;
		public var end:Point;
		public var control:Point;
		
		public function Segment(start:Point, end:Point, control:Point = null) 
		{
			this.start = start;
			this.end = end;
			this.control = control;
		}
		
		public function subdivide(k:Number):Segment
		{
			var _end:Point;
			if (control)
			{
				var k1:Number = 1.0 - k;
				
				var _control:Point = new Point(
					k * control.x + k1 * start.x,
					k * control.y + k1 * start.y);
				
				var temp:Point = new Point(
					k * end.x + k1 * control.x,
					k * end.y + k1 * control.y);
					
				_end = new Point(
					k * temp.x + k1 * _control.x,
					k * temp.y + k1 * _control.y);
				
				return new Segment(start, _end, _control);
			}
			else
			{
				_end = new Point(
					start.x + k * (end.x - start.x),
					start.y + k * (end.y - start.y));
				return new Segment(start, _end);
			}
		}
		
		public function get length():Number
		{
			if (control)
			{
				// code credit: The Algorithmist
				// http://algorithmist.wordpress.com/2009/01/05/quadratic-bezier-arc-length/
				var ax:Number = start.x - 2*control.x + end.x;
				var ay:Number = start.y - 2*control.y + end.y;
				var bx:Number = 2 * control.x - 2 * start.x;
				var by:Number = 2 * control.y - 2 * start.y;

				var a:Number = 4 * (ax * ax + ay * ay);
				var b:Number = 4 * (ax * bx + ay * by);
				var c:Number = bx * bx + by * by;

				var abc:Number = 2 * Math.sqrt(a + b + c);
				var a2:Number  = Math.sqrt(a);
				var a32:Number = 2 * a * a2;
				var c2:Number  = 2 * Math.sqrt(c);
				var ba:Number  = b / a2;

				return (a32 * abc + a2 * b * (abc - c2) + (4 * c * a - b * b) 
				  * Math.log((2 * a2 + ba + abc) / (ba + c2))) / (4 * a32);
			}
			else return end.subtract(start).length;
		}
	}
	
}