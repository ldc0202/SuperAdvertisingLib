package advertis.multimedia
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class MediaAbstract extends MovieClip implements IMedia
	{
		public static const CURRENT_STATIC_WAIT:String="wait";
		public static const CURRENT_STATIC_LOADING:String="loading";
		public static const CURRENT_STATIC_READY:String="ready";
		public static const CURRENT_STATIC_PLAYING:String="playing";
		public static const CURRENT_STATIC_STOP:String="stop";
		protected var _currentStatic:String="wait";
		private var _playMode:String="auto";
		public var mediaModel:MediaModel;
		public function MediaAbstract()
		{
			_currentStatic=MediaAbstract.CURRENT_STATIC_WAIT;
		}
		/**
		 * 媒体的当前状态：wait(等待)，loading(加载中)，ready(就绪),playing(播放中),stop(暂停)，
		 */
		public function get currentStatic():String
		{
			return _currentStatic;
		}
		/**
		 * 开始载入资源状态为loading
		 */
		public function startLoad():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_LOADING;
		}
		/**
		 * 载入资源完成状态为ready
		 */
		public function loaderComplete(event:Event=null):void
		{
			_currentStatic=MediaAbstract.CURRENT_STATIC_READY;
		}
		/**
		 * 开始播放资源状态为playing
		 */
		public function mediaPlay():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_PLAYING;
		}
		/**
		 * 暂停播放状态为stop
		 */
		public function mediaStop():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_STOP;
			
		}
		/**
		 * 此方法为什么用公共呢？仅因为弹幕文字时不在外部新建字体。
		 */
		public function addMedia(mediaM:MediaModel):void
		{
			mediaModel=mediaM;
			drawBg(true);
		}
		public function drawBg(t:Boolean):void{
			if(t){
				this.graphics.clear();
				this.graphics.beginFill(0x000000);
				this.graphics.drawRect(0,0,mediaModel.mediaWidth,mediaModel.mediaHeight);
				this.graphics.endFill();
			}else{
				this.graphics.clear();
			}
			
		}
		public function set playMode(value:String):void
		{
			_playMode=value;
		};
		public function get playMode():String
		{
			return _playMode;
		};
		
		public function removeAll():void{
			if(this.numChildren>0){
				this.removeChildAt(0);
				if(this.numChildren>0){
					removeAll();
				}
			}
		}
		public function hide():void{
			
		}
	}
}