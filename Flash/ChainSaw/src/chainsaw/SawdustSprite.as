package chainsaw
{
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.*;
	import spark.core.SpriteVisualElement;
	
	public class SawdustSprite extends SpriteVisualElement
	{
		//Embed sawdust pile image
		[Embed(source="../assets/sawdust_pile.png")]
		//[Bindable]
		public var mSawdustPile:Class;
		
		//private var mFuelArrowSprite:SpriteVisualElement= new SpriteVisualElement();
		private var BmpData:BitmapData = new mSawdustPile().bitmapData;
		
		public function Sawdust():void
		{
			loadImage();
		}
		
		private function loadImage():void
		{
			BmpData = new mSawdustPile().bitmapData;
			this.graphics.clear();
			this.graphics.beginBitmapFill(BmpData);
			this.graphics.drawRect(0, 0, BmpData.width, BmpData.height);
			this.graphics.endFill();
		}
		
		public function init():void
		{
			this.loadImage();
		}
	}
}