package chainsaw_assets {
	import flash.events.Event;
	import flash.display.*;
	
	public class Specks extends MovieClip{
		
		protected var wd:Number;
		protected var ht:Number;
		protected var color:uint;
		protected var dx:Number;
		protected var dy:Number;
		protected var dAlpha:Number = 1.0;
		protected var life:int;
		protected var frameCount:int;
		protected var isBlock:Boolean = true;
		protected var maxVel:Number = 10;
		protected var minVel:Number = 1;
		protected var alive:Boolean = true;
		protected var gravity:Number = .25;

		public function Specks(w:Number = 1, h:Number = 1, c:Number = 0x000000, l:int = 24, block:Boolean = true) {
			// constructor code
			this.enabled = false;
			
			wd = w;
			ht = h;
			color = c;
			life = l;
			graphics.lineStyle(0,color);
			graphics.beginFill(color,1.0);
			if(isBlock){
				graphics.drawRect(-(wd/2),-(ht/2), wd, ht);
			}else{
				graphics.drawEllipse(-(wd/2),-(ht/2), wd, ht);
			}
			reset();
		}
		
		public function reset():void{
			this.x = 0;
			this.y = 0;
			dy = -(Math.random() * maxVel/2) + (maxVel/4);
			dx = (Math.random()*maxVel) - (maxVel/2);
			frameCount = 0;
			visible = true;
			alive = true;
			addEventListener(Event.ENTER_FRAME, animate_frame);
		}

		private function animate_frame(e:Event):void{
			frameCount++;
			this.x += dx;
			this.y += (dy += gravity);
			if (frameCount >= life){
				alive = false;
				visible = false;
				removeEventListener(Event.ENTER_FRAME, animate_frame);
			}
		}
	}
	
}
