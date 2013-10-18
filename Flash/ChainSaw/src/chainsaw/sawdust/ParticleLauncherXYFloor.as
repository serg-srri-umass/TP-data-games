package chainsaw.sawdust {
	import flash.display.*;
	import flash.events.*;
	import flash.events.Event;
	
	public class ParticleLauncherXYFloor extends Sprite {
		
		public var maxParticleCount:int = 1200;
		public var maxParticlesPerFrame:int = 5;
		public var particleLimit:int = 0;
		public var particlesLaunched:int = 0;
		public var pLife:int = 48; //in frames
		public var pWidth:Number = 2;
		public var pHeight:Number = 2;
		public var pColor:uint = 0xFFFFFF;
		public var vectX:Number = 0;
		public var vectY:Number = 5;
		private var currentlyEmitting:Boolean = false;
		private var pArray:Array = new Array();
		public var speckCount:int = 0;
		private var atMaxCapacity:Boolean;
		public var useBlocks:Boolean = true;
		public var Rotation:Number = 10;
		public var RandomlyRotate:Boolean = true;
		public var xOffset:Number = 0;
		public var yOffset:Number = 0;
		public var yFloor:Number = 410;
		public var sizeVariance:Number = 0; //TODO

		public function ParticleLauncherXYFloor(xoffset:Number=0, yoffset:Number=0, floor:Number=0, color=0xFFFFFF):void
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
			var speck:SpecksXYFloor;
			while(parts < maxParticlesPerFrame && checkLimit(parts)){
				if(speckCount < maxParticleCount && !atMaxCapacity){
					//trace("particle " + parts);
					speck = new SpecksXYFloor(stage.mouseX+xOffset, stage.mouseY+yOffset,  pWidth, pHeight, pColor, pLife, useBlocks, Rotation, RandomlyRotate);
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
			for each(var speck:SpecksXYFloor in pArray)
			{
				speck.visible = false;
			}
		}
	}
	
}
