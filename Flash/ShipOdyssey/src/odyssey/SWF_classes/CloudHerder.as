package  {
	
	import flash.display.*;
	import flash.events.Event;
	
	public class CloudHerder extends MovieClip {
		
		public var cm:CloudMaker = new CloudMaker();
		public var mvArr:Array = new Array();
		public var velArr:Array = new Array();
		public var numClouds:int = 10;
		public var velocityScale:Number = 1;
		public var windVelocity:Number = Math.random();
		public var skyWidth:int;
		public var percentSpeed:Number = 1.0;
		
		//public var removalArray:Array = new Array();
		
		public function CloudHerder() {
		}
		
		public function init(dataArray:Array):void{
			var numberOfClouds:int = dataArray[0];
			var sWidth:int = dataArray[1];
			var baseColor:uint = dataArray[2];
			
			numClouds = numberOfClouds;
			skyWidth = sWidth;
			cm.setBaseColor(baseColor);
			for(var i:int=0; i<numClouds; i++){
				var mv:MovieClip = cm.createCloud();
				mv.x = Math.random() * skyWidth;
				mv.y = i*15+10;
				mv.scaleX = mv.scaleY = (1-((mv.y-30)/215));
				mvArr.push(mv);
				velArr.push(windVelocity * mv.scaleX);
				this.addChildAt(mv,0);
				//removalArray.push(mv);
			}
		}
		
		public function startClouds(){
			trace("there are " + mvArr.length + " clouds in the sky.");
			this.addEventListener(Event.ENTER_FRAME, moveCloud);
		}
		public function setCloudSpeed(speed:Number){
			percentSpeed = speed;
		}
		
		public function moveCloud(e:Event):void{
			//mv.x += .25;
			for(var i:int=0; i<numClouds; i++){
				mvArr[i].x += velArr[i] * percentSpeed;
				//if (mvArr[i].x - mvArr[i].width > stage.stageWidth){
				var b:Number = mvArr[i].getBounds(this).x;
				var c:int = skyWidth;
				var prevY:Number; var scale:Number; var mc:MovieClip;
				if (mvArr[i].getBounds(this).x > skyWidth && percentSpeed > 0){
					//cloud is offscreen right
					//trace("Object " + i + " is offscreen: " + mvArr[i].x + " and W: " + mvArr[i].width);
					//get old cloud info and kill original cloud
					prevY = mvArr[i].y;
					scale = mvArr[i].scaleX;
					this.removeChild(mvArr[i]);
					//create new cloud so clouds look different
					mc = cm.createCloud();
					mc.y = prevY;
					mc.scaleX = mvArr[i].scaleY = scale;
					mc.x = -mvArr[i].width - 20;
					velArr[i] = windVelocity * scale;
					mvArr[i] = mc;
					this.addChild(mvArr[i]);
					this.setChildIndex(mc, i);
				}
			}
		}
		
		public function cleanClouds():void{
			if(mvArr.length > 0){
				for(var i:int = 0; i < numClouds; i++){
					this.removeChild(mvArr[i]);
				}
				mvArr = new Array();
			}
		}
	}
}

