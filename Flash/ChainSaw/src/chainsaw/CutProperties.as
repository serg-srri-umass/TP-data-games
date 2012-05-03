package chainsaw
{
	import flash.display.MovieClip;

	public class CutProperties
	{
		var cutNumber;
		var log:int;
		var x_position;
		var top_to_bottom;
		
		public function CutProperties(cutNumber:int, log:int, x_pos:int, direction:Boolean)
		{
			this.cutNumber = cutNumber;
			this.log = log;
			this.x_position = x_pos;
			this.top_to_bottom = direction;
		}
		
		
		//
		//Static functions that check an array for a cut style
		//
		
		public static function determineStrategy(arr:Array):int
		{
			if(arr.length <= 1) return -1;
			
			//flags -- 0==null, 1==directional, -1==vertical
			//flags -- 0==null, 1==downward, -1==up/down
			var style_a:int = 0;
			var style_b:int = 0;
			
			//First: check to see if the first two cuts are on the same log
			if(arr[0].log == arr[1].log){
				//If they are...
				if(CutProperties.isDirectional(arr)){
					style_a = 1;
				}
				
			} else {
				//If they are not...
				if(CutProperties.isVertical(arr)){
					style_a = -1;
				}
			}
			
			//now find cut direction (down or up/down)			
			if(isDownward(arr))
				style_b = 1;
			if(isUpDown(arr))
				style_b = -1;
			
			//now return the style
			{
				if(style_a == 1){
					if(style_b == 1){
						return 0;
					}
					else if(style_b == -1){
						return 1;
					}
				}
				if(style_a == -1){
					if(style_b == 1){
						return 2;
					}
					else {
						return 3;
					}
				}
				
				//otherwise
				return -1;
			}
		}
		
		public static function isDirectional(arr:Array):Boolean
		{
			var tolerance:int=2;
			var outliers:int=0;
			
			var changeLog:int = 1;
			var currentLog:int = arr[0].log;
			var lastX:int = arr[0].x_position;
			
			for(var i:int=0; i<arr.length; i++)
			{
				if(arr[i].log != currentLog) // the player changed logs
				{
					currentLog = arr[i].log;
					changeLog++;
					if(changeLog > 4)
						if(++outliers > tolerance)
							return false;
				}
				else //on same log
				{
					/*
					if(arr[i].log % 2 == 1) // Direction: Left to Right (logs 1&3)
					{
						if(arr[i].x_position < lastX)
							if(++outliers > tolerance)
								return false;
					}
					else if(arr[i].log % 2 == 0) // Direction: Right to Left (logs 2&4)
					{
						if(arr[i].x_position > lastX)
							if(++outliers > tolerance)
								return false;
					}
					*/
				}
				lastX = arr[i].x_position;
			}
			
			return true; //it has passed
		}
		
		public static function isVertical(arr:Array):Boolean
		{
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
		
		public static function isDownward(arr:Array):Boolean
		{
			var i:int;
			//TODO outliers?
			for(i=0; i<arr.length; i++)
			{
				if(arr[i].top_to_bottom == false)
				{
					return false;
				}
			}
			return true;
		}
		
		public static function isUpDown(arr:Array):Boolean
		{
			var tolerance:int=2;
			var outliers:int=0;
			var changeLog:int = 1;
			var currentLog:int = arr[0].log;
			var mod:int = 0;
			for(var i:int=0; i<arr.length; i++) //alternating
			{
				if(arr[i].top_to_bottom != (i%2 == mod)){ //if cut is in wrong direction
					if(arr[i].log != currentLog)//if cut is on a different log
					{
						currentLog = arr[i].log;
						changeLog++;
						if(changeLog > 4) return false;
						mod = mod?0:1; //flip mod between 0 and 1
					}
					else						//deviation on same log
					{
						if(i==0) mod = mod?0:1; //It's ok if the first cut is bottom to top
							
						else if(++outliers > tolerance){
							return false;
						}
					}
				}
			}
			return true;
		}
		
	}
}