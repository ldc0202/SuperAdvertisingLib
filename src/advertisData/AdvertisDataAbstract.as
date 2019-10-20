package advertisData
{
	public class AdvertisDataAbstract implements IadvertisData
	{
		private var _advertisWidth:Number=1920;
		private var _advertisHeight:Number=1080;
		private var _advertisModels:Object;
		private var _backgroundURL:String;
		private var _backgroundColor:uint=0x000000;
		private var _bgColorAlpha:Number=1;
		public function AdvertisDataAbstract()
		{
			
		}
		public function set advertisModels(value:Object):void
		{
			_advertisModels=value;
		}
		public function get advertisModels():Object
		{
		    return _advertisModels;
		}
		
		public function set backgroundURL(url:String):void
		{
		    _backgroundURL=url;
		}
		public function get backgroundURL():String
		{
			return _backgroundURL;
		}
		public function set initWidth(value:Number):void
		{
			_advertisWidth=value;
		}
		public function get initWidth():Number
		{
		    return _advertisWidth;
		}
		
		public function set initHeight(value:Number):void
		{
			_advertisHeight=value;
		}
		public function get initHeight():Number{
		    return _advertisHeight;
		}
		
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor=value;
		}
		public function get backgroundColor():uint
		{
		    return _backgroundColor;
		}
		public function set bgColorAlpha(value:Number):void
		{
			_bgColorAlpha=value;
		}
		public function get bgColorAlpha():Number
		{
			return _bgColorAlpha;
		}
	}
}