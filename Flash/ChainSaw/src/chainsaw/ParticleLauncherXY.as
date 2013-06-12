package chainsaw_assets {
	import flash.display.*;
	import flash.events.*;
	import flash.events.Event;
	import loaded_assets.SpecksXY;
	
	public class ParticleLauncherXY extends Sprite{
		
		private var maxParticleCount:int;
		private var maxParticlesPerFrame:int = 10;
		private var particleLimit:int = 0;
		private var particlesLaunched:int = 0;
		public var pLife:int = 24; //in frames
		public var pWidth:Number = 1;
		public var pHeight:Number = 1;
		public var pColor:uint = 0xFFE1C1;
		public var vectX:Number = 0;
		public var vectY:Number = 1;
		private var currentlyEmitting:Boolean = false;
		private var pArray:Array = new Array();
		public var speckCount:int = 0;
		private var atMaxCapacity:Boolean;
		public var useBlocks:Boolean = true;
		public var Rotation:Number = 0;
		public var RandomlyRotate:Boolean = false;
		public var xOffset:Number = 0;
		public var yOffset:Number = 0;


		public function ParticleLauncherXY() {
			// constructor code
			//this.enabled = false;
			this.mouseEnabled = false;
			this.mouseChildren = false;
			maxParticleCount = maxParticlesPerFrame * pLife;
			pArray = new Array(maxParticleCount);
			atMaxCapacity = false;
		}
		public function setMaxParticlesPerFrame(maxParts:int):void{
			maxParticlesPerFrame = maxParts;
			maxParticleCount = maxParticlesPerFrame * pLife;
			pArray = new Array(maxParticleCount);
		}
		public function setParticleLifespan(lifeInFrames:int):void{
			pLife = lifeInFrames;
			maxParticleCount = maxParticlesPerFrame * pLife;
			pArray = new Array(maxParticleCount);
		}

		public function startParticleAnim():void{
			//trace("start Particle anim");
			particleLimit = 0;
			this.addEventListener(Event.ENTER_FRAME, generateParticles);
			currentlyEmitting = true;
		}
		public function startLimitedParticleAnim(i:int):void{
			//limited number of particles launched
			particlesLaunched = 0;
			particleLimit = i;
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
			var speck:SpecksXY;
			while(parts < maxParticlesPerFrame && checkLimit(parts)){
				if(speckCount < maxParticleCount && !atMaxCapacity){
					//trace("particle " + parts);
					speck = new SpecksXY(stage.mouseX+xOffset, stage.mouseY+yOffset,  pWidth, pHeight, pColor, pLife, useBlocks, Rotation, RandomlyRotate);
					pArray[speckCount] = speck;
					addChild(speck);
				}else{
					atMaxCapacity = true;
					speckCount = speckCount % maxParticleCount;
					pArray[speckCount].reset(stage.mouseX+xOffset, stage.mouseY+yOffset);
				}
				speckCount++;
				parts++;
				particlesLaunched++;
			}			
		}
		
		private function checkLimit(pts:int):Boolean{
			if (particleLimit == 0) return true;
			else if(particlesLaunched<particleLimit) return true;
			return false;
		}
	}
	
}
