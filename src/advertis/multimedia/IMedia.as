package advertis.multimedia
{
	public interface IMedia
	{
		function addMedia(mediaModel:MediaModel):void;
		/**
		 * 播放模式设置
		 * @param value="auto"时为自动轮播模式；
		 * @param value="trig"时为推动模式；
		 */
		function set playMode(value:String):void;
		function get playMode():String;
		function hide():void;
	}
}