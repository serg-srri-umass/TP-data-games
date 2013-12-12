package odyssey
{
	import flash.events.MouseEvent;
	
	public class VideoControlsMVC extends videoControlsMVC
	{
		private var _playPauseFunc:Function, _replayFunc:Function, _closeFunc:Function;
		public function VideoControlsMVC( playPauseFunc, replayFunc, closeFunc)
		{
			super();
			_playPauseFunc = playPauseFunc;
			_replayFunc = replayFunc;
			_closeFunc = closeFunc;
			
			mainBtn.setClickFunctions(_playPauseFunc, _playPauseFunc);
			replayBtn.addEventListener( MouseEvent.CLICK, _replayFunc);
			closeBtn.addEventListener( MouseEvent.CLICK, _closeFunc);
		}
	}
}