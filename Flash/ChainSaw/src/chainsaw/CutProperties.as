package chainsaw
{
	import flash.display.MovieClip;

	public class CutProperties
	{
		var cutNumber;
		var log:int;
		var x_position;
		var top_to_bottom; //direction
		
		public function CutProperties(cutNumber:int, log:int, x_pos:int, direction:Boolean)
		{
			this.cutNumber = cutNumber;
			this.log = log;
			this.x_position = x_pos;
			this.top_to_bottom = direction;
		}
		
		
		/**
		 * A comparison function to be used by Array.sort()
		 * @return 
		 */
//		A negative return value specifies that A appears before B in the sorted sequence.
//		A return value of 0 specifies that A and B have the same sort order.
//		A positive return value specifies that A appears after B in the sorted sequence.
		public static function compare(arg1:*, arg2:*):int
		{
			//TODO
			return 0;
		}
		
		//
		//Static functions that check an array for a cut style
		//
		
		public static function checkDirectional(arr:Array):Boolean
		{
			trace("CutProperties.checkDirectional()");
			
			var tolerance:int=2;
			var outliers:int=0;
			
			var changeLog:int = 1;
			var currentLog:int = arr[0].log;
			var lastX:int = arr[0].x_position;
//			var direction:int = arr[1].x_position-lastX;
			
			for(var i:int=0; i<arr.length; i++)
			{
				if(arr[i].log != currentLog)
				{
					trace("[NEW LOG] " + currentLog);
					currentLog = arr[i].log;
					changeLog++;
//					direction*=-1;
					if(changeLog > 4)
						if(++outliers > tolerance)
							return false;
				}
				else //on same log
				{
					trace("same log: " + currentLog, "outliers", outliers);
					if(arr[i].log % 2 == 1) // Direction: Left to Right (logs 1&3)
					{
						trace("direction: L-R");
						if(arr[i].x_position < lastX)
							if(++outliers > tolerance)
								return false;
					}
					else if(arr[i].log % 2 == 0) // Direction: Right to Left (logs 2&4)
					{
						trace("direction: R-L");
						if(arr[i].x_position > lastX)
							if(++outliers > tolerance)
								return false;
					}
				}
				lastX = arr[i].x_position;
			}
			
			trace("\nCut method: directional");
			trace("Outliers:", outliers);
			
//			//TODO check if player used downward cuts only, or used a zig-zag up/down pattern
//			for(var j:int=0; j<arr.length; j++){
//				var b:Boolean = arr[j].top_to_bottom;
//				trace("TOP TO BOTTOM", b);
//			}
			
			return true; //it has passed
		}
		public static function checkOutwardIn(arr:Array):Boolean
		{
			trace("CutProperties.checkOutwardIn()");
			
			var tolerance:int=6;
			var outliers:int=0;

			var changeLog:int = 1;
			var currentLog:int = arr[0].log;
			var lastX:int = arr[0].x_position;
			var lastX2:int = arr[0].x_position;
			
			var boundLeft:int = 0;
			var boundRight:int= 1000; //no need to have exact number, 1000 is big enough
			
			for(var i:int=0; i<arr.length; i++)
			{
				if(arr[i].log != currentLog) //changed log
				{
					trace("[NEW LOG] " + currentLog);
					currentLog = arr[i].log;
					
					boundLeft = 0;
					boundRight= 1000;
					
					if(++changeLog > 4)
						if(++outliers > tolerance)
							return false;
				}
				else //on same log
				{
					if(arr[i].x_position < boundLeft || arr[i].x_position > boundRight)
					{
						if(++outliers > tolerance)
							return false;
					}
					
					if(true)
					{//replace this
						if(arr[i].cutNumber % 2 == 1) {
							boundLeft = arr[i].x_position;
						} else {
							boundRight = arr[i].x_position;
						}
					}
					if(false)
					{//with this
						//with this method, order doesn't matter
						//however, it can accept 'directional' style cuts
						var pos:int = arr[i].x_position;
						var a:int = Math.abs(boundLeft - pos);
						var b:int = Math.abs(boundRight - pos);
						
						if(a < b) {
							boundLeft = arr[i].x_position;
						} else {
							boundRight = arr[i].x_position;
						}
					}
				}
				
//				//if the last three cuts are in the same direction
//				if( (lastX2<lastX && lastX<arr[i].x_position) || (lastX2>lastX && lastX>arr[i].x_position) )
//				{
//					//trace(">Outliers", outliers);
//					if(++outliers > tolerance)
//						return false;
//				}
				
				lastX2 = lastX;
				lastX = arr[i].x_position;
				
				trace("outliers:", outliers);
			}
			
			trace("\nCut method: Outward-In");
			trace("Outliers:", outliers);
			
			return true; //it has passed
		}
		public static function checkVertical(arr:Array):Boolean
		{
			trace("CutProperties.checkVertical()");
			var tolerance:int=2;
			var outliers:int=0;
			var lastLog:int = 1;
			for(var i:int=0; i<arr.length; i++)
			{
				if(arr[i].log==1){ //first log
					if(Math.abs(arr[i].log - lastLog) > 1){
						if(lastLog!=4){
							if(++outliers > tolerance)
								return false;
						}
					}
				} else if(arr[i].log==4){ //fourth log
					if(Math.abs(arr[i].log - lastLog) > 1){
						if(lastLog!=1){
							if(++outliers > tolerance)
								return false;
						}
					}
				} else {
					if(Math.abs(arr[i].log - lastLog) > 1){
						if(++outliers > tolerance)
							return false;
					}
				}
				lastLog = arr[i].log;
				trace("outliers:", outliers);
			}
			return true;
		}
		
		public static function findCutDirectionStyle(arr:Array):String
		{
			var style_zigzag:Boolean = true;
			var style_topdown:Boolean = true;
			var i:int;
			
			for(i=0; i<arr.length; i++) //all downward
			{
				if(arr[i].top_to_bottom == false){
					style_topdown = false;
					break;
				}
			}
			
			var tolerance:int=2;
			var outliers:int=0;
			var changeLog:int = 1;
			var currentLog:int = arr[0].log;
			var mod:int = 0;
			for(i=0; i<arr.length; i++) //alternating (zig-zag)
			{
				if(arr[i].top_to_bottom != (i%2 == mod)){ //if cut is in wrong direction
					if(arr[i].log != currentLog){ //if cut is on a different log
						currentLog = arr[i].log;
						changeLog++;
						mod = mod?0:1; //flip mod between 0 and 1
					}
					else {
						if(i==0) mod = mod?0:1;
						else if(++outliers > tolerance){
							style_zigzag = false;
							break;
						}
					}
				}
			}
			
			if(style_zigzag){
				return ", zig-zag cuts";
			} else if(style_topdown){
				return ", downward cuts";
			}
			
			//if there is not a consistant vertical direction:
			return "";
		}
	}
}