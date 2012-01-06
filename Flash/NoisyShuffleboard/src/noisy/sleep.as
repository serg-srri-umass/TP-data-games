package noisy
{
	// sleep() waits for a number of milliseconds (duration) before exiting.
	public function sleep(duration:uint):void
	{
		// Time is based on # of milliseconds since 1/1/1970. Mechanism here is simply
		// to keep checking the time elapsed until surpassing the input duration. There
		// is no sleep operation in ActionScript, and its use of timers is very
		// operation-specific.
		var startDate:Date			= new Date();
		var currentMoment:Number	= startDate.getTime();	
		var endMoment:Number		= currentMoment + duration;
		
		while (currentMoment < endMoment)
		{
			var currentDate:Date = new Date();
			currentMoment = currentDate.getTime();
		}
	}
}