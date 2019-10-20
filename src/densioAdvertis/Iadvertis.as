package densioAdvertis
{
	/**
	 * 广告发布接口
	 * @author densio
	 */
	public interface Iadvertis
	{
		function set advertisModels(value:Object):void;
		function get advertisModels():Object;
		
		function set backgroundURL(url:String):void;
		function get backgroundURL():String;
		
		function set initWidth(value:Number):void;
		function get initWidth():Number;
		
		function set initHeight(value:Number):void;
		function get initHeight():Number;
		
		function set backgroundColor(value:uint):void;
		function get backgroundColor():uint;
		
		/**
		 * 播放模式设置默认为auto是自动轮播模式；trig时为推动模式；
		 */
		function set playMode(value:String):void;
		function get playMode():String;

	}
}