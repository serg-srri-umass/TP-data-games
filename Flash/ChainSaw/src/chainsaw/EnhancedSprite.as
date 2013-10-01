package chainsaw
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.BlendMode;
	
	import spark.core.SpriteVisualElement;
	
	public class EnhancedSprite extends SpriteVisualElement
	{
		private var _data:BitmapData;
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
			_data = _image.bitmapData;
			
			this.blendMode = BlendMode.NORMAL;
			this.graphics.clear();
			this.graphics.beginBitmapFill(_data);
			this.graphics.drawRect(0, 0, _data.width, _data.height);
			this.graphics.endFill();
		}
		
		public function getWidth():int
		{
			return _data.width;
		}
		
		public function getHeight():int
		{
			return _data.height;
		}
	}
}