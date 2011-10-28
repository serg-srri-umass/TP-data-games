package
{
	import flash.display.*;
	import flash.events.*;
	
	public class Particle extends MovieClip
	{
		var _life:uint=24;
		var _frame:uint=0;
		var max_vel:Number = 6;
		var min_vel:Number = 1;
		var _size = 0;
		var _size_variance=0;
		var rotationSpeed=0;
		var particle_direction=0;
		var _velocity=0;
		var x_vel=0;
		var y_vel=0;
		var _theta:Number=0;
		var _gravity:Number = .20; //accelleration due to gravity
		public var _dead:Boolean = false;
		
		public function Particle()
		{
			x = 0; //temp
			y = 0; //temp
			
			_velocity = (Math.random() * (max_vel-min_vel)) + min_vel;
//			_velocity = Math.random() * 100;
			//trace(_velocity);
			_theta=Math.random() * 2*Math.PI;
			x_vel = Math.cos(_theta) * _velocity;
			y_vel = Math.sin(_theta) * _velocity;
			
			//size variance
			_size_variance = 4;
			var size_min = .5;
			var size_max = .9;
			
			_size = Math.random() * size_max;
			
			this.scaleX = _size;
			this.scaleY = _size;
			
			_gravity+=(_size/8);
			
			this.addEventListener(Event.ENTER_FRAME, animate_frame);
		}
		
		//does animation of the individual particle each _frame
		function animate_frame(e:Event)
		{
			_frame++;
			this.x += x_vel;
			this.y += (y_vel+=_gravity);
			if(_frame > _life) {
//				trace("DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//				trace(parent);
				_dead = true;
				//parent.destroyParticle(this);
				//classPropertyMcRef = null;
			}
		}
		
		function prepareForDeletion()
		{
			this.removeEventListener(Event.ENTER_FRAME, animate_frame);
			this.stop();
			
			_life			= null;
			_frame			= null;
			max_vel			= null;
			min_vel			= null;
			_size			= null;
			_size_variance	= null;
			rotationSpeed	= null;
			particle_direction= null;
			_velocity		= null;
			x_vel			= null;
			y_vel			= null;
			_theta			= null;
			_gravity		= null;
			_dead			= null;
		}
	}
}