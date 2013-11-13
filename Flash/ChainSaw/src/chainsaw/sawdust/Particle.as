package chainsaw.sawdust {
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	public class Particle extends Shape {
		
		private var wd:Number;						// width
		private var ht:Number;						// height
		private var color:uint;						// particle color
		private var dx:Number;						// amount to move each frame in the x direction
		private var dy:Number;						// amount to move each frame in the y direction
		private var dAlpha:Number = 1.0;			// particle transparency
		private var life:int;						// life of the particle (in frames)
		private var frameCount:int;					// how many frames have elapsed
		private var isBlock:Boolean = true;			// should the particle be square shaped
		private var maxVel:Number = 10;				// maximum velocity
		private var minVel:Number = 1;				// minimum velocity
		private var alive:Boolean = true;			// is the particle 'alive' (above the floor)
		private var gravity:Number = .5;			// how much gravity should effect the particles
		private var rotateBy:Number = 0;			// degrees to rotate each frame
		private var sizeVariance:Number = 0;		// how much to vary the size
		
		private var relativeFloor:Boolean = false;
		private var yFloor:Number = 9999999;
		private var initY:Number = 0;
		
		/**
		 * 
		 * @param X x-position
		 * @param Y y-position
		 * @param w width
		 * @param h height
		 * @param c color
		 * @param l life
		 * @param block isBlock
		 * @param rot rotation
		 * @param randomlyRotate
		 * @param alphaVal transparency
		 */
		public function Particle(X:Number, Y:Number, w:Number = 1, h:Number = 1,
							   sizeVar:Number=0, c:Number = 0x000000, varyBrightness:Number=0, l:int = 24,
							   block:Boolean = true, rot:Number = 0,
							   randomlyRotate:Boolean = false, alphaVal:Number = 0.99) {
			// constructor code
			
			//mouseEnabled = false;
			initY = Y;
			wd = w;
			ht = h;
			color = c;
			life = l;
			isBlock = block;
			dAlpha = alphaVal;
			sizeVariance = sizeVar;
			
			//vary the size of the particle
			var size:Number = 1+(Math.random()*sizeVariance*2)-sizeVariance;
			this.scaleX = size;
			this.scaleY = size;
			
			//vary the brightness of the color
			var offset:Number = ((Math.random()*2)-1) * varyBrightness; 
			this.transform.colorTransform = new ColorTransform(1,1,1,1,offset,offset,offset,0);
			
			if (randomlyRotate){
				rotateBy = (Math.random()-.5)*rot;
			}else{
				rotateBy = rot;
			}
			
			graphics.lineStyle(0,color);
			graphics.beginFill(color,1.0);
			if(isBlock){
				graphics.drawRect(-(wd/2),-(ht/2), wd, ht);
			}else{
				graphics.drawEllipse(-(wd/2),-(ht/2), wd, ht);
			}
			reset(X,Y);
		}
		
		public function reset(X:Number, Y:Number):void{
			this.x = X;
			this.y = Y;
			dy = -(Math.random() * maxVel/1.5) + (maxVel/4);
			dx = (Math.random()*maxVel) - (maxVel/2);
			frameCount = 0;
			alpha = dAlpha;
			visible = true;
			alive = true;
			addEventListener(Event.ENTER_FRAME, animate_frame,false,0,true);
		}

		private function animate_frame(e:Event):void{
			//frameCount++;
			this.x += dx;
			this.y += (dy += gravity);
			this.rotation += rotateBy;
			this.alpha *= dAlpha;
			if (checkFloor()){
				removeEventListener(Event.ENTER_FRAME, animate_frame);
				alive = false;
				//visible = false;
			}
		}
		
		public function setYFloor(i:int):void{
			yFloor = i;
		}
		public function setRelativeFloor(bool:Boolean):void{
			relativeFloor = bool;
		}
		
		private function checkFloor():Boolean{
			if(relativeFloor){
				if(this.y >= yFloor + initY)
					return true;
			}else if(this.y >= yFloor)
				return true;
			return false;
		}
	}
	
}
