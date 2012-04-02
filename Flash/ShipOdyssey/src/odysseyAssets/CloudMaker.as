//****Code by SRRI and Tristan Warneke, 2012; Released under Open Source (MIT) License****

package odysseyAssets{

	import flash.display.MovieClip;
	import flash.display.Graphics;
	import flash.filters.BlurFilter;
	import flash.filters.ConvolutionFilter;

	public class CloudMaker{
		var maxLobes:int = 50;
		var minLobes:int = 30;
		var baseRadius:int = 60;
		var baseColor:uint = 0xAAAAAA;
		
		public function createCloud(br:int = 30):MovieClip {
			baseRadius = br;
			var radius:int = baseRadius;
			var radius2:int = baseRadius;
			var color:uint = baseColor;
			var lobes:int = Math.random()*(maxLobes-minLobes)+minLobes; //random number of lobes between max and min
			radius = 40; //found these values looked better
			radius2 = 20;
			var mv = new MovieClip();
			var X:int = 0; var Y:int = 0;
			
			for(var i:int=0; i<lobes; i++){
				mv.graphics.beginFill(color, .45); //fill the draw figure with current color at alpha = .45
				mv.graphics.drawEllipse(X, Y, radius*2, radius2*2); //draw ellipse
				//mv.graphics.drawCircle(X, Y, radius); 	//decided to use ellipse, gives better results
				mv.graphics.endFill();						//necessary call in Flash or overlapping drawing creates holes instead of overlaps
				
				//adjustments for next lobe to draw
				X += (Math.random()* radius*2)-(radius);	//move X for the next cloud somewhere between -1 and 1 radius away
				Y += (Math.random()* radius2*2)-(radius2);	//move Y ...
				radius += Math.random()*2 - 1 ;				//adjust X Radius between -1 and 1
				radius2 += Math.random()*2 - 1 ;			//adjust Y radius between -1 and 1
				
				color += 0x020202;							//increase the color towards white to give it a somewhat 3d effect as it layers
				if(color > 0xFFFFFF) color = 0xFFFFFF;
			}
			var blurFilt:BlurFilter = new BlurFilter(10,5,5); //create blur filter BlurFilter(BlurX, BlurY, quality/passes)
			//var convFilt:ConvolutionFilter = new ConvolutionFilter(3,3,new Array(0,1,0,1,-3,1,0,1,0),0); //matrix transform blur filter
			mv.filters = [blurFilt]; 	//blur the cloud
			return mv; 					//return the cloud as a movie clip --Flash speciic
		}
		
		//setters... not complete, should probably add all to encapsulate
		public function setBaseColor(bc:uint):void{
			baseColor = bc;
		}
	}

}