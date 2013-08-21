package chainsaw.sound{
	
	import flash.utils.Dictionary;
	
		/*Provides secondary debug functionality to check on sounds manipulated in SoundHandler. 
		Stores entries of AdvancedSoundStates, can print information from these states. Possible 
		uses are printing states of sounds when an error occurs, regular intervals of state checking, etc. */
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
		
		/*returns an Array with information about what sounds are playing, not playing, fading in, and fading out. 
		key is as follows: [0]=numSoundsPlaying, [1]=numSoundsFadingIn, [2]=numSoundsFadingOut, [3]=numSoundsNotPlaying*/
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