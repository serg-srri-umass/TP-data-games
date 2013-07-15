package{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Rectangle;
	import odyssey.events.ZoomEvent;

	public class BoatSailAnim extends MovieClip{
		public var frameCount:int = 0;
		public var baseY:Number;
		public var baseX:Number;
		public var waveHeight:Number = 5;
		public var waveHeightStore:Number = 0;
		public var waveLength:Number = 18;
		public var waveStep:Number = 0;
		public var dx:Number = .05;
		public var ddx:Number = 0;
		public var dRot:Number = 0;
		public var basePointY;
		public var YOffset;
		public var waterBaseY;
		public var finalX:Number = -11.55;
		public var finalY:Number = -142.05;
		public var waveTime:int = 72; //time it takes the boat to slow in frames
		public var zoomTime:int = 36; //in frames
		public var xZoomStep:Number = 0;
		public var yZoomStep:Number = 0;
		public var hwZoomStep:Number = 0;
		public var zoomPercent:Number = 645;
		public var zoomCounter = 0;
		//var reflectionOffset = Reflection.y-ToyBoat.y;

		public function BoatSailAnim(){
			this.addEventListener(Event.ENTER_FRAME, BoatBob);

			BowPoint.visible = false;
			AftPoint.visible = false;
			baseY = ToyBoat.y;
			baseX  = ToyBoat.x;
			basePointY = AftPoint.y;
			YOffset = ToyBoat.y - AftPoint.y;
			waterBaseY = ToyBoat.TBWave.y;
			sendCraneToFrame(100);
			scale.gotoAndStop("off");
			ToyBoat.crane.hook.chest.visible = false;
		}
		
		public function sendCraneToFrame(arg:int):void{
			ToyBoat.crane.gotoAndStop(arg);
		}
		
		public function BoatBob(e:Event):void{
			frameCount++;
			var wavePart = frameCount/waveLength;
			var forWavePart = (frameCount+13)/waveLength;
			AftPoint.y = basePointY + Math.sin(wavePart)*waveHeight;
			BowPoint.y = basePointY + Math.sin(forWavePart)*waveHeight;
			ToyBoat.y = (AftPoint.y+BowPoint.y)/2 + YOffset;
			ToyBoat.rotation = 360 * Math.atan2((AftPoint.y-BowPoint.y) , (AftPoint.x-BowPoint.x)) / Math.PI;
			ToyBoat.TBWave.y = waterBaseY - Math.min(AftPoint.y-basePointY, BowPoint.y-basePointY);
			ToyBoat.TBWave.rotation = 360 - ToyBoat.rotation;
		}

		public function slowSwells(e:Event):void{
			waveHeight -= waveStep;
			if (waveHeight <= 0){
				waveHeight = 0;
				this.removeEventListener(Event.ENTER_FRAME, BoatBob);
				this.removeEventListener(Event.ENTER_FRAME, slowSwells);
				this.addEventListener(Event.ENTER_FRAME, zoomStepIn);
			}
		}
		public function startSwells(e:Event):void{
			waveHeight += waveStep;
			if (waveHeight >= waveHeightStore){
				waveHeight = waveHeightStore;
				this.removeEventListener(Event.ENTER_FRAME, startSwells);
			}
		}
		
		public function zoomStepIn(e:Event):void{
			ToyBoat.x += xZoomStep; 
			ToyBoat.y += yZoomStep;
			ToyBoat.scaleX = ToyBoat.scaleY = (ToyBoat.scaleY+hwZoomStep/100);
			zoomCounter++;

			// 15 frames before the animation finishes, play the scale "fadeIn" animation 
			if(zoomCounter == zoomTime - 15)
				scale.gotoAndPlay("fadeIn");
			
			if(zoomCounter == zoomTime){
				this.removeEventListener(Event.ENTER_FRAME, zoomStepIn);
				dispatchEvent(new ZoomEvent(ZoomEvent.IN));
			}
		}
		
		public function zoomStepOut(e:Event):void{
			ToyBoat.x += xZoomStep; 
			ToyBoat.y += yZoomStep;			
			ToyBoat.scaleX = ToyBoat.scaleY = (ToyBoat.scaleY+hwZoomStep/100);
			zoomCounter++;
			
			// bring the crane to stowed position
			ToyBoat.crane.nextFrame();
			ToyBoat.crane.nextFrame();
						
			if(zoomCounter == zoomTime){
				dispatchEvent(new ZoomEvent(ZoomEvent.OUT));
				this.removeEventListener(Event.ENTER_FRAME, zoomStepOut);
				this.addEventListener(Event.ENTER_FRAME, startSwells);
				this.addEventListener(Event.ENTER_FRAME, BoatBob);
			}
		}
		public function hardReset(e:Event = null):void{
			reset();
			sendCraneToFrame(100);
			scale.gotoAndStop("off");
			ToyBoat.gotoAndStop(59);
			ToyBoat.startSail();
		}
		public function doZoomIn():void{
			ToyBoat.stopSail();
			zoomCounter = 0;
			waveHeightStore = waveHeight;
			waveStep = waveHeight/waveTime;
			xZoomStep = (finalX - ToyBoat.x)/zoomTime;
			yZoomStep = (finalY - ToyBoat.y)/zoomTime;
			hwZoomStep = (zoomPercent - 100)/zoomTime;
			ToyBoat.crane.hook.chest.visible = false;
			this.addEventListener(Event.ENTER_FRAME, slowSwells);
		}
		public function doZoomOut(haveTreasure:Boolean = false):void{
			ToyBoat.startSail();
			zoomCounter = 0;
			//ToyBoat.visible = true;
			waveStep = waveHeightStore/waveTime;
			xZoomStep = -xZoomStep;
			yZoomStep = -yZoomStep;
			hwZoomStep = -hwZoomStep;
			scale.gotoAndPlay("fadeOut");
			ToyBoat.crane.hook.chest.visible = haveTreasure;
			this.addEventListener(Event.ENTER_FRAME, zoomStepOut);
		}
		
		public function reset():void{
			ToyBoat.x = baseX;
			ToyBoat.y = baseY;
			ToyBoat.scaleX = ToyBoat.scaleY = 1;
			sendCraneToFrame(100);
			this.addEventListener(Event.ENTER_FRAME, startSwells);
			this.addEventListener(Event.ENTER_FRAME, BoatBob);
			ToyBoat.crane.hook.chest.visible = false;
		}
	}
}












	
