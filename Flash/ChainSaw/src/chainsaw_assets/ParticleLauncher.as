package chainsaw_assets {
	import flash.events.*;
	import flash.events.Event;
	import flash.display.MovieClip;
	
	public class ParticleLauncher extends MovieClip {
		
		protected var maxParticleCount:int;
		protected var maxParticlesPerFrame:int = 10;
		protected var pLife:int = 24; //in frames
		protected var pWidth:Number = 1;
		protected var pHeight:Number = 1;
		protected var pColor:uint = 0xFFE1C1;
		protected var currentlyEmitting:Boolean = false;
		protected var pArray:Array = new Array();
		protected var speckCount:int = 0;
		protected var atMaxCapacity:Boolean;


		public function ParticleLauncher() {
			// constructor code
			this.enabled = false;
			this.mouseChildren = false;
			maxParticleCount = maxParticlesPerFrame * pLife;
			pArray = new Array(maxParticleCount);
			atMaxCapacity = false;
		}

		public function startParticleAnim():void{
			//trace("start Particle anim");
			this.addEventListener(Event.ENTER_FRAME, generateParticles);
			currentlyEmitting = true;
		}

		public function stopParticleAnim():void{
			if (currentlyEmitting)
			this.removeEventListener(Event.ENTER_FRAME, generateParticles);
			currentlyEmitting = false;
		}
		
		public function generateParticles(e:Event):void {
			//trace("generating particles");
			var parts:int = 0;
			var speck:Specks;
			while(parts < maxParticlesPerFrame){
				if(speckCount < maxParticleCount && !atMaxCapacity){
					//trace("particle " + parts);
					speck = new Specks(pWidth, pHeight, pColor, pLife, true);
					pArray[speckCount] = speck;
					addChild(speck);
				}else{
					atMaxCapacity = true;
					speckCount = speckCount % maxParticleCount;
					pArray[speckCount].reset();
				}
				speckCount++;
				parts++;
			}
//			for(var i:int = 0; i<pArray.length; i++){
//				if (!pArray[i].alive){
//					//removeChild(pArray[i]);
//					pArray = pArray.splice(i,1);
//					i--;
//				}
//			}
			
		}
	}
	
}
