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
			var tolerance:int=2;
			var outliers:int=0;
			
			var changeLog:int = 1;
			var currentLog:int = arr[0].log;
			var lastX:int = arr[0].x_position;
			
			for(var i:int=0; i<arr.length; i++)
			{
				if(arr[i].log != currentLog)
				{
//					trace("[NEW LOG] " + currentLog);
					currentLog = arr[i].log;
					changeLog++;
					if(changeLog > 4)
						if(++outliers > tolerance)
							return false;
				}
				else //on same log
				{
//					trace("same log: " + currentLog, "outliers", outliers);
					if(arr[i].log % 2 == 1) // Direction: Left to Right (logs 1&3)
					{
//						trace("direction: L-R");
						if(arr[i].x_position < lastX)
							if(++outliers > tolerance)
								return false;
					}
					else if(arr[i].log % 2 == 0) // Direction: Right to Left (logs 2&4)
					{
//						trace("direction: R-L");
						if(arr[i].x_position > lastX)
							if(++outliers > tolerance)
								return false;
					}
				}
				lastX = arr[i].x_position;
			}
			
			return true; //it has passed
		}
		
		public static function checkVertical(arr:Array):Boolean
		{
//			trace("CutProperties.checkVertical()");
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
//				trace("outliers:", outliers);
			}
			return true;
		}
		
		public static function findCutDirectionStyle(arr:Array):String
		{
			var style_topdown:Boolean = true;
			var style_zigzag:Boolean = true;
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
					if(arr[i].log != currentLog){	//if cut is on a different log
						currentLog = arr[i].log;
						changeLog++;
						if(changeLog > 4) style_zigzag = false;
						mod = mod?0:1; //flip mod between 0 and 1
					}
					else {							//deviation on same log
						if(i==0) mod = mod?0:1; //It's ok if the first cut is bottom to top
						
						else if(++outliers > tolerance){
							style_zigzag = false;
							break;
						}
					}
				}
			}
			
			if(style_topdown){
				return ", downward cuts";
			} else if(style_zigzag){
				return ", zig-zag cuts";
			}
			
			//if there is not a consistant vertical direction:
			return "";
		}
	}
}