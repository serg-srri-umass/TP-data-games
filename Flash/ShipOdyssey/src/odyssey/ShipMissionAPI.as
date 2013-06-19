package odyssey
{
	import flash.display.SimpleButton;
	import flash.events.Event;
	
	public class ShipMissionAPI
	{
		public var getHuntMission:Function;
		public var getCurrentMission:Function;
		public var restartMission:Function;
		public var setGameTitle:Function;

		private var startFirstHunt:Function;
		private var startSecondHunt:Function;
		private var startThirdHunt:Function;
		private var startFourthHunt:Function;
		
		public function ShipMissionAPI (first:Function, second:Function, third:Function, fourth:Function, restart:Function, cm:Function, hm:Function, setGTitle:Function) {
			startFirstHunt = first;
			startSecondHunt = second;
			startThirdHunt = third;
			startFourthHunt = fourth;
			restartMission = restart;
			getCurrentMission = cm;
			getHuntMission = hm;
			setGameTitle = setGTitle;
		}
		
		public function startHunt(num:int, e:Event = null, autoStart:Boolean = false):void {
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