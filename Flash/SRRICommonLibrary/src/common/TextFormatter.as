package common
{
	public class TextFormatter
	{
		public static function toCash(arg:int):String{
			var stringArg:String = String(arg);
			var outputString:String = "$";
			var backwardsString:String = "";
			var ticker:int = 0;
			
			for( var i:int = stringArg.length; i >= 0; i--){
				backwardsString += stringArg.charAt(i);
				if(ticker == 3 && i > 0){
					backwardsString += ",";
					ticker = 0;
				}
				ticker++;
			}
			for( var j:int = backwardsString.length; j >= 0; j--)
				outputString += backwardsString.charAt(j);
			
			return outputString;
		}
	}
}