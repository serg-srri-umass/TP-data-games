package odyssey
{
	import flash.events.Event;
	import odyssey.missions.Missions;
	import odyssey.missions.MissionData;

	
	public class ShipMissionAPI
	{
		private var beginGame:Function;
		public var getCurrentMission:Function;
		public var setGameTitle:Function;
		public var closeGame:Function;
		
		public function ShipMissionAPI( beginFunc:Function, currentGameFunc:Function, setTitleFunc:Function, closeGameFunc:Function) {
			beginGame = beginFunc;
			getCurrentMission = currentGameFunc;
			setGameTitle = setTitleFunc;
			closeGame = closeGameFunc;
		}
		
		public function startHunt( missionNum:int, e:Event = null):void {
			var md:MissionData = Missions.getMission( missionNum);
			var stripBtnListeners:Boolean = (e ? true : false);
			beginGame( md, stripBtnListeners);
		}
	}
}