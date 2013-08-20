package chainsaw.sound{
	public class AdvancedSoundState{
		
		//constructor
		public function AdvancedSoundState(name:String, isPlaying:Boolean, isFadingIn:Boolean, isFadingOut:Boolean){
			this.name = name;
			this.isPlaying = isPlaying;
			this.isFadingIn = isFadingIn;
			this.isFadingOut = isFadingOut; 
		}
		
		private var name:String = "";
		private var isPlaying:Boolean = false; 
		private var isFadingIn:Boolean = false;
		private var isFadingOut:Boolean = false;  
		
		//setters and getters
		public function getName():String{
			return name;
		}
		
		public function setIsPlaying(isPlaying:Boolean):void{
			this.isPlaying = isPlaying;
		}
		
		public function setIsFadingIn(isFadingIn:Boolean):void{
			this.isFadingIn = isFadingIn;
		}
		
		public function setIsFadingOut(isFadingOut:Boolean):void{
			this.isFadingOut = isFadingOut;
		}
		
		public function toString():String{
			return "Name:" + name + "  Playing?" + isPlaying + "  Fading in?" + isFadingIn + "  Fading out?"
				 + isFadingOut + "\n";
		}
	}
}