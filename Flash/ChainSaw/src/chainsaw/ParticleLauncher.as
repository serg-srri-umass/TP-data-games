package chainsaw_assets {
	import flash.events.*;
	import flash.events.Event;
	import flash.display.MovieClip;
	import loaded_assets.Specks;
	
	public class ParticleLauncher extends MovieClip {
		
		private var maxParticleCount:int;
		private var maxParticlesPerFrame:int = 10;
		public var pLife:int = 24; //in frames
		public var pWidth:Number = 1;
		public var pHeight:Number = 1;
		public var pColor:uint = 0xFFE1C1;
		private var currentlyEmitting:Boolean = false;
		private var pArray:Array = new Array();
		public var speckCount:int = 0;
		private var atMaxCapacity:Boolean;
		public var useBlocks:Boolean = true;
		public var Rotation:Number = 0;
		public var RandomlyRotate:Boolean = false;


		public function ParticleLauncher() {
			// constructor code
			this.enabled = false;
			this.mouseChildren = false;
			maxParticleCount = maxParticlesPerFrame * pLife;
			pArray = new Array(maxParticleCount);
			atMaxCapacity = false;
		}

		public function startParticleAnim():void{
			trace("start Particle anim");
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
					speck = new Specks( pWidth, pHeight, pColor, pLife, useBlocks, Rotation, RandomlyRotate);
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
		}
	}
	
}
