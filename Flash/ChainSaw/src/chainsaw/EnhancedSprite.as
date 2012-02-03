package chainsaw
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	import spark.core.SpriteVisualElement;
	
	public class EnhancedSprite extends SpriteVisualElement
	{
		private var data:BitmapData;
		private var _image:*;
		
		public function EnhancedSprite(image:Class=null)
		{
			super();
			if(image!=null) {
				loadImage(image);
			}
		}
		
		public function loadImage(image:Class):void
		{
			_image = new image();
			data = _image.bitmapData;
			
			this.blendMode = "multiply";
			this.graphics.clear();
			this.graphics.beginBitmapFill(data);
			this.graphics.drawRect(0, 0, data.width, data.height);
			this.graphics.endFill();
		}
		
		public function getWidth():int
		{
			return data.width;
		}
		
		public function getHeight():int
		{
			return data.height;
		}
	}
}