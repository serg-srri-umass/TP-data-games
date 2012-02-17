package chainsaw
{
	import flash.display.MovieClip;

	public class CutProperties
	{
		var cutNumber;
		var log:int;
		var x_position;
		var top_to_bottom; //direction
		
		public function CutProperties(cutNumber:int, log:int, x_pos:int)
		{
			this.cutNumber = cutNumber;
			this.log = log;
			this.x_position = x_pos;
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
			var direction:int = arr[1].x_position-lastX;
			
			for(var i:int=0; i<arr.length; i++)
			{
				if(arr[i].log != currentLog)
				{
					currentLog = arr[i].log;
					changeLog++;
//					lastX=arr[i].x_position;
					direction*=-1;
					if(changeLog > 4)
						if(++outliers > tolerance)
							return false;
				}
				else //on same log
				{	
					if(arr[i].cutNumber % 2 == 1) //going left to right (logs 1&3)
					{
						if(arr[i].x_position <= lastX)
							if(++outliers > tolerance)
								return false;
					}
					else if(arr[i].cutNumber % 2 == 0) //going right to left (logs 2&4)
					{
						if(arr[i].x_position >= lastX)
							if(++outliers > tolerance)
								return false;
					}
					
//					lastX = arr[i].x_position;
				}
				lastX = arr[i].x_position;
				
//				if( ((arr[i].x_position-lastX) * direction) >= 0)
//					if(++outliers > tolerance)
//						return false;
			}
			
			return true; //it has passed
		}
		public static function checkOutterToInner(arr:Array):Boolean
		{
			var tolerance:int=2;
			var outliers:int=0;

			var changeLog:int = 1;
			var currentLog:int = arr[0].log;
			var lastX:int = arr[0].x_position;
			
			var lastBound:int;
			var boundLeft:int = 0;
			var boundRight:int= 1000; //no need to have exact number, 1000 is big enough
			
			for(var i:int=0; i<arr.length; i++)
			{
				if(arr[i].log != currentLog) //changed log
				{
					currentLog = arr[i].log;
//					lastX=arr[i].x_position;
					
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
					
					if(arr[i].cutNumber % 2 == 1) {
						boundLeft = arr[i].x_position;
					} else {
						boundRight = arr[i].x_position;
					}
					
//					lastX = arr[i].x_position;
				}
				lastX = arr[i].x_position;
			}
			
			return true; //it has passed
		}
		public static function checkVertical(arr:Array):Boolean
		{
//			for(var i:int=0; i<arr.length; i++)
//			{
//				if(arr[i].log != ((i%4)+1) ) return false;
//			}
//			return true;
			
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
			}
			return true;
		}
	}
}