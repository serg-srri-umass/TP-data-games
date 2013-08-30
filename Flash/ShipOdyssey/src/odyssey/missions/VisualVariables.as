package odyssey.missions
{
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	
	public class VisualVariables
	{
		// water gradients:
		public static var murkyWater:LinearGradient = new LinearGradient();
			private static var murkyWater1:GradientEntry = new GradientEntry(0x796f5a, 0.33, 0.75);
			private static var murkyWater2:GradientEntry = new GradientEntry(0x645a45, 0.66, 0.75);
			murkyWater.entries = [murkyWater1, murkyWater2];
			murkyWater.rotation = 90;
		
		public static var clearWater:LinearGradient = new LinearGradient();
			private static var clearWater1:GradientEntry = new GradientEntry(0x076FA3, 0.33, 0.75);
			private static var clearWater2:GradientEntry = new GradientEntry(0x025987, 0.66, 0.75);
			clearWater.entries = [clearWater1, clearWater2];
			clearWater.rotation = 90;
		
		public static var greenWater:LinearGradient = new LinearGradient();
			private static var greenWater1:GradientEntry = new GradientEntry(0x6ba898, 0.33, 0.75);
			private static var greenWater2:GradientEntry = new GradientEntry(0x1cdbc1, 0.66, 0.75);
			greenWater.entries = [greenWater1, greenWater2];
			greenWater.rotation = 90;
		
		// sky gradients:
		public static var daylight:LinearGradient = new LinearGradient();
			private static var daylight1:GradientEntry = new GradientEntry(0x3BCFF3, 0, 0.75);
			private static var daylight2:GradientEntry = new GradientEntry(0xBFEFFB, 0.66, 0.75);
			daylight.entries = [daylight1, daylight2];
			daylight.rotation = 90;
		
		public static var evening:LinearGradient = new LinearGradient();
			private static var evening1:GradientEntry = new GradientEntry(0xb197ed, 0, 0.75);
			private static var evening2:GradientEntry = new GradientEntry(0x346dd1, 0.66, 0.75);
			evening.entries = [evening1, evening2];
			evening.rotation = 90;
		
		public static var darkDay:LinearGradient = new LinearGradient();
			private static var darkDay1:GradientEntry = new GradientEntry(0x002358, 0, 0.75);
			private static var darkDay2:GradientEntry = new GradientEntry(0x77787E, 0.66, 0.75);
			darkDay.entries = [darkDay1, darkDay2];
			darkDay.rotation = 90;
			
		// cloud patterns:
		// first value is how many clouds. Second is their width. Third is color.
		public static var fluffyClouds:Array = new Array(5,395,0xDDDDDD);
		public static var grayClouds:Array = new Array(5,395,0x999999);
	}
}