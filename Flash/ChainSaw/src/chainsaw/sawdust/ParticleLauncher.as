package chainsaw.sawdust {
	import flash.display.*;
	import flash.events.*;
	import flash.events.Event;
	
	public class ParticleLauncher extends Sprite {
		
		public var maxParticleCount:int = 1200;			// maximum particles to generate total
		public var maxParticlesPerFrame:int = 5;		// maximum particles to generate each frame
		public var particleLimit:int = 0;				// 
		public var particlesLaunched:int = 0;			// particles created so far
		public var pLife:int = 48;						// life of each particle (in frames)
		public var pWidth:Number = 2;					// width of each particle
		public var pHeight:Number = 2;					// height of each particle
		public var pColor:uint = 0xFFFFFF;				// color of each particle
		private var currentlyEmitting:Boolean = false;	// if the launcher is actively generating particles
		private var pArray:Array = new Array();			// Array to store the particles
		public var speckCount:int = 0;					// particles created so far
		private var atMaxCapacity:Boolean;				// if there are less particles than the maximum
		public var useBlocks:Boolean = true;			// should the particles be square/rectangular
		public var Rotation:Number = 10;				// amount to rotate particles
		public var RandomlyRotate:Boolean = true;		// add randomness to the particles' rotation
		public var xOffset:Number = 0;					// 
		public var yOffset:Number = 0;					//
		public var yFloor:Number = 410;					// the height of the invisible 'floor' which particles should stop at
		public var sizeVariance:Number = 0.5;			// how much variation there should be in particles' size from the specified size
		public var brightnessVariance:Number = 10;		// how much variation there should be in particles' brightness/darkness

		public function ParticleLauncher(xoffset:Number=0, yoffset:Number=0, floor:Number=0, color:uint=0xFFFFFF):void
		{
			//this.enabled = false;
			this.mouseEnabled = false;
			this.mouseChildren = false;
			//maxParticleCount = maxParticlesPerFrame * pLife;
			pArray = new Array(maxParticleCount);
			atMaxCapacity = false;
			
			this.xOffset = xoffset;
			this.yOffset = yoffset;
			this.yFloor = floor;
			this.pColor = color;
		}
		
		public function setMaxParticlesPerFrame(maxParts:int):void{
			maxParticlesPerFrame = maxParts;
			//maxParticleCount = maxParticlesPerFrame * pLife;
			pArray = new Array(maxParticleCount);
		}
		public function setParticleLifespan(lifeInFrames:int):void{
			pLife = lifeInFrames;
			//maxParticleCount = maxParticlesPerFrame * pLife;
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
			var speck:Particle;
			while(parts < maxParticlesPerFrame && checkLimit(parts)){
				if(speckCount < maxParticleCount && !atMaxCapacity){
					//trace("particle " + parts);
					speck = new Particle(stage.mouseX+xOffset, stage.mouseY+yOffset,  pWidth, pHeight, sizeVariance, pColor, brightnessVariance, pLife, useBlocks, Rotation, RandomlyRotate);
					//speck.dy = -10;
					speck.setYFloor(yFloor);
					pArray[speckCount] = speck;
					addChild(speck);
					speck.visible = true;
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
		
		public function setFloor(floor:Number):void
		{
			this.yFloor = floor;
		}
		
		// Clears are particles from the screen
		public function clearParticles():void
		{
			for each(var speck:Particle in pArray)
			{
				speck.visible = false;
			}
		}
	}
	
}
