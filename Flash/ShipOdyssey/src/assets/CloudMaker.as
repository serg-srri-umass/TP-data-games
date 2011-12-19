package assets{

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
			var lobes:int = Math.random()*(maxLobes-minLobes)+minLobes;
			radius = 40;
			radius2 = 20;
			var mv = new MovieClip();
			var X:int = 0; var Y:int = 0;
			
			for(var i:int=0; i<lobes; i++){
				mv.graphics.beginFill(color, .45);
				mv.graphics.drawEllipse(X, Y, radius*2, radius2*2);
				//mv.graphics.drawCircle(X, Y, radius);
				X += (Math.random()* radius*2)-(radius);
				Y += (Math.random()* radius2*2)-(radius2);
				radius += Math.random()*2 - 1 ;
				radius2 += Math.random()*2 - 1 ;
				mv.graphics.endFill();
				color += 0x020202;
				if(color > 0xFFFFFF)
					color = 0xFFFFFF;
			}
			var blurFilt:BlurFilter = new BlurFilter(10,5,5);
			//var convFilt:ConvolutionFilter = new ConvolutionFilter(3,3,new Array(0,1,0,1,-3,1,0,1,0),0);
			mv.filters = [blurFilt];
			return mv;
		}
		public function setBaseColor(bc:uint):void{
			baseColor = bc;
		}
	}

}