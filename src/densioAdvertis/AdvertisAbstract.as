package densioAdvertis
{
	import flash.display.Sprite;
	
	import advertisData.IadvertisData;
	
	public class AdvertisAbstract extends Sprite implements Iadvertis
	{
		public function AdvertisAbstract(advertisD:IadvertisData)
		{
			_advertisData=advertisD;
			_advertisModels=advertisD.advertisModels;
		}
		private var _advertisWidth:Number;
		private var _advertisHeight:Number;
		private var _advertisModels:Object;
		private var _backgroundURL:String;
		private var _backgroundColor:uint;
		private var _advertisData:IadvertisData;
		private var _playMode:String="auto";

		public function set advertisModels(value:Object):void{
			_advertisModels=value;
		}
		public function get advertisModels():Object{
			return _advertisModels;
		}
		/**
		 * 背景图
		 */
		public function set backgroundURL(url:String):void{
			_backgroundURL=url;
		}
		public function get backgroundURL():String{
			return _backgroundURL;
		}
		/**
		 * 媒体的宽
		 */
		public function set initWidth(value:Number):void{
			_advertisWidth=value;
		}
		public function get initWidth():Number{
			return _advertisWidth;
		}
		/**
		 * 媒体的高
		 */
		public function set initHeight(value:Number):void{
			_advertisHeight=value;
		}
		public function get initHeight():Number{
			return _advertisHeight;
		}
		/**
		 * 背景颜色
		 */
		public function set backgroundColor(value:uint):void{
			_backgroundColor=value;
		}
		public function get backgroundColor():uint{
			return _backgroundColor;
		}
		/**
		 * 设置自动播放“auto”或控制“tirg”，控制时由addAdvertis()放法更新。
		 */
		public function set playMode(value:String):void
		{
			_playMode = value;
		}
		
		public function get playMode():String
		{
			return _playMode;
		}


	}
}