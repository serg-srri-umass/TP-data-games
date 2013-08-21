package chainsaw.sound{
	import flash.utils.Dictionary;
	
		public class SoundDebug{
		
		
		public var stateList:Dictionary = new Dictionary();
		
		//constructor
		public function SoundDebug(){
			
		}
		
		public function addEntry(soundState:AdvancedSoundState):void{
			stateList[soundState.getSoundID()] = soundState;
		}
		
		public function removeEntry(id:int):void{
			delete stateList[id];
		}
		
		public function printState():void{
			for each(var entry:AdvancedSoundState in stateList){
				trace(entry.toString());
			}
		}
		
		public function getNumSounds():int{
			var count:int = 0;
			for each(var entry:AdvancedSoundState in stateList){
				count++;
			}
			return count;
		}
		
		public function getNumSoundsPlaying():Array{
			var outputArray:Array = [0, 0, 0, 0];
			for each(var entry:AdvancedSoundState in stateList){
				if(entry.getIsPlaying()){
					outputArray[0]++;
				}else{
					outputArray[3]++;
				}
				if(entry.getIsFadingIn()){
					outputArray[1]++;
				}
				if(entry.getIsFadingOut()){
					outputArray[2]++;
				}
				if(entry.getIsFadingIn() && entry.getIsFadingOut()){
					throw new Error("name: " + entry.getName() + " ID: " + entry.getSoundID() + " sound is fading in and out at same time");
				}
			}
			return outputArray;
		}
	}
}