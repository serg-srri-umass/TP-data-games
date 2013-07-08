package odyssey
{
	public class DebugMode
	{
		// when this is set to true, the drop hook button is grayed out until at least 1 rat is sent.
		public static const DISABLE_DROP_BUTTON:Boolean = true;
		
		// when this is set to true, the treasure location prints out to the console.
		public static const PRINT_TREASURE_LOCATION:Boolean = true;
		
		// when this is false, you pay for every hook you drop. When its true, you only have to pay for the misses.
		public static const ONLY_PAY_MISSED_HOOKS:Boolean = true;
	}
}