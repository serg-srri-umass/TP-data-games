package common
{
	public class DebugUtilities
	{
		/* Code from http://michaelvandaniker.com/blog/2008/11/25/how-to-check-debug-swf/ */
		// Returns whether or not the .swf was compiled in debug mode.
		private static var hasDeterminedDebugStatus:Boolean = false;
		public static function get isDebug():Boolean
		{
			if(!hasDeterminedDebugStatus)
			{
				try
				{
					throw new Error();
				}
				catch(e:Error)
				{
					var stackTrace:String = e.getStackTrace();
					_isDebug = stackTrace != null && stackTrace.indexOf("[") != -1;
					hasDeterminedDebugStatus = true;
					return _isDebug;
				}
			}
			return _isDebug;
		}
		private static var _isDebug:Boolean;
		
		// throw an error if the assertion fails, and we are in a debug build
		//	example:
		//		assert( arrayIndex <= array.length, "arrayIndex too high" );
		public static function assert( expression:Boolean, failMessage:String ):void
		{
			if ( isDebug && !expression)
				throw new Error( "Assertion failed: "+failMessage );
		}
	}
}