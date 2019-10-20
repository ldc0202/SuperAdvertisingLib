package advertisData
{
	public interface IadvertisData
	{
		/**
		 * 传入数据MediaModel的Obj集合
		 * @param mediaWidth=媒体的宽度；
		 * @param mediaWidth=媒体的高度；
		 * @param type=jpg/png/gif/swf/flv/mp4；
		 * @param mediaUrl=媒体的本地或网络地址；
		 * @param residenceTime=停留时间,以毫秒为单位1秒=1000毫秒；
		 * type为swf/flv/mp4时自动设为影片时长。
		 */
		function set advertisModels(value:Object):void;
	    function get advertisModels():Object;
		
		/**
		 * 背景图片地址
		 */
		function set backgroundURL(url:String):void;
		function get backgroundURL():String;
		/**
		 * 媒体容器的宽
		 */
		function set initWidth(value:Number):void;
		function get initWidth():Number;
		/**
		 * 媒体容器的高
		 */
		function set initHeight(value:Number):void;
		function get initHeight():Number;
		/**
		 * 背景色
		 */
		function set backgroundColor(value:uint):void;
		function get backgroundColor():uint;
		/**
		 * 背景色透明度
		 */
		function set bgColorAlpha(value:Number):void;
		function get bgColorAlpha():Number;
	}
}