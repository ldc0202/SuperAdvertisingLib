package advertis.multimedia
{
	import advertis.SuperAdvertis;

	public class MediaModel
	{
		public static const IMAGE_JPG:String="jpg";
		public static const IMAGE_JPEG:String="jpeg";
		public static const IMAGE_JPE:String="jpe";
		public static const IMAGE_PNG:String="png";
		public static const IMAGE_PNS:String="pns";
		public static const IMAGE_GIF:String="gif";
		public static const MOVIE_SWF:String="swf";
		public static const MOVIE_FLV:String="flv";
		public static const MOVIE_MP4:String="mp4";
		public static const MOVIE_F4V:String="f4v";
		public static const TEXT:String="text";
		public static const TEXT_BEHAVIOR_SINGLE:String="single";//单行
		public static const TEXT_BEHAVIOR_AUTO:String="auto";//多行自动换行
		public static const TEXT_BEHAVIOR_SUBTITLE:String="subtitle";//滚动（推送）的单行文本
		public static const WINDOWS:String="windows";//视频弹窗
		
		public var windowsCtrlSuperAdvertis:SuperAdvertis;
		public var ID:String="";
		/**
		 * 媒体的宽
		 */
		public var mediaWidth:Number=0;
		/**
		 * 媒体的高
		 */
		public var mediaHeight:Number=0;
		/**
		 * 本地媒体的地址
		 */
		public var mediaUrl:String="";
		/**
		 * 特殊个例：用于大图作为背景，中间播视频。视频播完切换底图。
		 */
		public var pPath:String="";
		/**
		 * 特殊个例：用于大图作为背景，中间播视频。视频播完切换底图。媒体的类型如："jpg","png","gif","swf","flv","mp4","f4v","text"
		 */
		public var pType:String="";
		/**
		 * 服务器媒体的地址
		 */
		public var mediaNetUrl:String="";
		/**
		 * 媒体的类型如："jpg","png","gif","swf","flv","mp4","f4v","text"
		 */
		public var type:String=MediaModel.IMAGE_JPG;
		/**
		 * 播放的次数uint
		 */
		public var frequency:uint=1;
		/**
		 * 每次停留时间,以毫秒为单位1秒=1000毫秒；只对图片有效
		 */
		public var residenceTime:Number=5000;
		
		private var _transtionNum:int=6;
		/**
		 * 排序
		 */
		public var order:String="0";
		/**
		 * 文字类型时
		 */
		public var textModel:TextModel;
		public var layOutModel:Object;
		public function MediaModel(obj:Object=null)
		{
			if(obj==null){return};
			this.mediaWidth=Number(obj.layoutWidth);
			this.mediaHeight=Number(obj.layoutHeight);
			this.ID=obj.MIDS_QueueGUID;
			this.type=obj.Type =="TXT" ? "TEXT" : obj.Type;
			this.type=this.type.toLocaleLowerCase();
			this.frequency=obj.PlayCount ? uint(obj.PlayCount) : 1;
			this.residenceTime=Number(obj.SwitchingTime)*1000;
			this.order=obj.Order;
			var switchingMode:String=obj.SwitchingMode ? obj.SwitchingMode : "7";
			this.transtionNum=getTrastionNum(String(obj.SwitchingMode));
			this.mediaUrl=obj.mediaUrl;
			this.mediaNetUrl=obj.mediaNetUrl;
			this.pPath=obj.PPath;
			this.pType=obj.PType;
		}
		private function getTrastionNum(str:String):int{
			var arr:Array=[];
			var n:int=7;
			if(str !="undefined" && str.length>0){
				arr=str.split(",");
				n= arr.length>1 ? int(arr[Math.floor(arr.length*Math.random())]) : int(arr[0]);
			}
			return n;
		}
		/**
		 * @param transtionNum 切换效果动画：0，遮帘过渡 1，淡化过渡，2，照片过渡。3，像素溶解过渡。4。挤压过渡，5，向左滚动。6，向右滚动，7，左右随机。
		 */
		public function get transtionNum():int
		{
			//_transtionNum=Math.floor(7*Math.random());
			//_transtionNum=0;
			return _transtionNum;
		}
		public function set transtionNum(value:int):void
		{
			_transtionNum = value;
		}
		

	}
}