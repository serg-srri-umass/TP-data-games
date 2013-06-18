package odyssey
{
	import flash.display.SimpleButton;
	import flash.events.Event;
	
	public class ShipMissionAPI
	{
		public var getHuntMission:Function;
		public var getCurrentMission:Function;
		public var restartMission:Function;

		private var startFirstHunt:Function;
		private var startSecondHunt:Function;
		private var startThirdHunt:Function;
		private var startFourthHunt:Function;
		
		public function ShipMissionAPI (first:Function, second:Function, third:Function, fourth:Function, restart:Function, cm:Function, hm:Function) {
			startFirstHunt = first;
			startSecondHunt = second;
			startThirdHunt = third;
			startFourthHunt = fourth;
			restartMission = restart;
			getCurrentMission = cm;
			getHuntMission = hm;
		}
		
		public function startHunt(num:*, e:Event = null, autoStart:Boolean = false):void {
			if(num is String) {
				if(num == "LEVEL 1")
					startFirstHunt(e, autoStart);
				else if(num == "LEVEL 2")
					startSecondHunt(e, autoStart);
				else if(num == "LEVEL 3")
					startThirdHunt(e, autoStart);
				else if(num == "LEVEL 4")
					startFourthHunt(e, autoStart);
			} else {
				if(num == 1)
					startFirstHunt(e, autoStart);
				else if(num == 2)
					startSecondHunt(e, autoStart);
				else if(num == 3)
					startThirdHunt(e, autoStart);
				else if(num == 4)
					startFourthHunt(e, autoStart);
			} 
		}
	}
}