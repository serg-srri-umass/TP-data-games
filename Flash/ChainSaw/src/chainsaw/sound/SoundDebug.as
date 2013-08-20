package chainsaw.sound{
	import flash.utils.Dictionary;
	
		public class SoundDebug{
		
		public var stateList:Dictionary = new Dictionary();
		
		//constructor
		public function SoundDebug(){
			
		}
		
		public function addEntry(soundState:AdvancedSoundState):void{
			stateList[soundState.getName()] = soundState;
		}
		
		public function printState():void{
			for each(var entry:AdvancedSoundState in stateList){
				trace(entry.toString());
			}
		}
	}
}