package chainsaw_assets {
	import flash.events.Event;
	import flash.display.*;
	
	public class SpecksXY extends Shape{
		
		private var wd:Number;
		private var ht:Number;
		private var color:uint;
		private var dx:Number;
		private var dy:Number;
		
		private var dAlpha:Number = 1.0;
		private var life:int;
		private var frameCount:int;
		private var isBlock:Boolean = true;
		private var maxVel:Number = 10;
		private var minVel:Number = 1;
		private var alive:Boolean = true;
		private var gravity:Number = .25;
		private var rotateBy:Number = 0;

		public function SpecksXY(X:Number, Y:Number, w:Number = 1, h:Number = 1,
							   c:Number = 0x000000, lifeInFrames:int = 24,
							   block:Boolean = true, rot:Number = 0,
							   randomlyRotate:Boolean = false, alphaVal:Number = 0.99) {
			// constructor code
			
			//mouseEnabled = false;
			wd = w;
			ht = h;
			color = c;
			life = lifeInFrames;
			isBlock = block;
			dAlpha = alphaVal;
			
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
			//this.x = stage.mouseX;
			//this.y = stage.mouseY;
			dy = -(Math.random() * maxVel/1.5) + (maxVel/4);
			dx = (Math.random()*maxVel) - (maxVel/2);
			frameCount = 0;
			alpha = 1.0;
			visible = true;
			alive = true;
			addEventListener(Event.ENTER_FRAME, animate_frame);
		}

		private function animate_frame(e:Event):void{
			frameCount++;
			this.x += dx;
			this.y += (dy += gravity);
			this.rotation += rotateBy;
			this.alpha *= dAlpha;
			if (frameCount >= life){
				removeEventListener(Event.ENTER_FRAME, animate_frame);
				alive = false;
				visible = false;
				
			}
		}
	}
	
}
