package
{
	import flash.events.*;
	import flash.display.*;
	
	public class Emitter extends flash.display.Sprite
	{
		var _particles:Array;
		var particles_per_frame:uint = 10;
		var num_particles:uint = 0;
		
		public function Emitter()
		{
			trace("NEW emitter instantiated");
			
			_particles = new Array();
			
			this.addEventListener(Event.ENTER_FRAME, createParticles);
		}
		
		function createParticles(e:Event)
		{
			//create new particles
			for(var i:int; i<particles_per_frame; i++)
			{
				num_particles++;
				//trace(num_particles+" particles");
				//trace(_particles.length+" particles");
				var particle:Particle = new Particle();
				_particles.push(particle);
				addChild(particle);
			}
			
			for each (var p:Particle in _particles){

			}
			
			//MovieClip(this.root).addChild(new Particle());
			
			for (i=0; i<_particles.length; i++)
			{
				if(_particles[i]._dead)
				{
					_particles[i].prepareForDeletion();
					//destroyParticle(p);
					removeChild(_particles[i]);
					
					_particles.splice(i,1);
				}
			}
		}
		
		public function destroyParticle(p:Particle):void
		{
			removeChild(p);
			//TODO
		}
	}
}