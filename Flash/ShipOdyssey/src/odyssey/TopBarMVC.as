package odyssey
{
	import flash.display.MovieClip;
	public class TopBarMVC extends topBar_mvc
	{
		
		public function setTitle(arg:String):void{
			title.text = arg;
		}
		public function setVersion(arg:String):void{
			version.text = arg;
		}
	}
}