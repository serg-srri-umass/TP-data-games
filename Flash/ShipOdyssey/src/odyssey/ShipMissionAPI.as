package odyssey
{
	import flash.events.Event;
	import odyssey.missions.Missions;
	import odyssey.missions.MissionData;

	
	public class ShipMissionAPI
	{
		private var beginGame:Function;
		//public var getHuntMission:Function; // OBSOLETE, same as GetCurrentMission()
		public var getCurrentMission:Function;
		//public var restartMission:Function;
		public var setGameTitle:Function;
		
		public function ShipMissionAPI( beginFunc:Function, /*restart:Function,*/ currentGameFunc:Function, /*hm:Function,*/ setTitleFunc:Function) {
			beginGame = beginFunc;
			//restartMission = restart;
			getCurrentMission = currentGameFunc;
			//getHuntMission = hm;
			setGameTitle = setTitleFunc;
		}
		
		public function startHunt( missionNum:int, e:Event = null, clearPreviousData:Boolean = false):void {
			var md:MissionData = Missions.getMission( missionNum);
			var stripBtnListeners:Boolean = (e ? true : false);
			beginGame( md, stripBtnListeners, clearPreviousData);
		}
	}
}