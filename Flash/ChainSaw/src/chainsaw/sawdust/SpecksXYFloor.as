package chainsaw.sawdust {
	import flash.display.*;
	import flash.events.Event;
	
	public class SpecksXYFloor extends Shape {
		
		private var wd:Number;
		private var ht:Number;
		private var color:uint;
		private var dx:Number;
		public var dy:Number;
		protected var dAlpha:Number = 1.0;
		private var life:int;
		private var frameCount:int;
		private var isBlock:Boolean = true;
		private var maxVel:Number = 10;
		private var minVel:Number = 1;
		private var alive:Boolean = true;
		private var gravity:Number = .5;
		private var rotateBy:Number = 0;
		
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
		public function SpecksXYFloor(X:Number, Y:Number, w:Number = 1, h:Number = 1,
							   c:Number = 0x000000, l:int = 24,
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
//			this.scaleX = 2;
//			this.scaleY = 2;
			
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
//			alpha = 1.0;
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
//			this.scaleX = this.scaleY = 5;
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
