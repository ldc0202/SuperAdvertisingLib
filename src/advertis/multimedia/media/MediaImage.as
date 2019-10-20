package advertis.multimedia.media
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import advertis.SuperAdvertis;
	import advertis.multimedia.IMedia;
	import advertis.multimedia.MediaAbstract;
	import advertis.multimedia.MediaModel;
	
	import events.AppEvent;
	
	public class MediaImage extends MediaAbstract implements IMedia
	{
		private var _moutimediaWidth:Number;
		private var _moutimediaHeight:Number;
		private var _moutimediaUrl:String
		private var _loader:Loader;
		private var _type:String="image";
		
		private var _timer:Timer;
		private var _residenceTime:Number;
		private var _loading:Loading;
		private var _frequency:uint;
		public function MediaImage(mediaModel:Object)
		{
			super();
			addMedia(MediaModel(mediaModel));
		}
		override public function addMedia(mediaM:MediaModel):void{
			super.addMedia(mediaM);
			this.mediaModel=mediaM;
			_moutimediaWidth=mediaM.mediaWidth;
			_moutimediaHeight=mediaM.mediaHeight;
			_moutimediaUrl=mediaM.mediaUrl;
			_frequency=mediaM.frequency;
			_type=mediaM.type;
			_residenceTime=mediaM.residenceTime;
		}
		override public function startLoad():void{
			trace(mediaModel.mediaUrl,"开始加载");
			_currentStatic=MediaAbstract.CURRENT_STATIC_LOADING;
			_timer=new Timer(_residenceTime,_frequency);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,timerCompleteHandler);
			_loader=new Loader();
			addChild(_loading=new Loading(_moutimediaWidth,_moutimediaHeight));
			addChild(_loader);
			var urlRequest:URLRequest=new URLRequest(_moutimediaUrl);
			_loader.load(urlRequest);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
		}
		override public function mediaPlay():void{
			if(!_timer){
				startLoad();
			}else{
				_timer.start();
			}
			trace(mediaModel.mediaUrl,"开始播放");
			_currentStatic=MediaAbstract.CURRENT_STATIC_PLAYING;
			var obj:Object=new Object();
			if(mediaModel.pPath!="" && mediaModel.pType!=""){
				obj.show=true;
				obj.mediaModel=mediaModel;
				playMode=SuperAdvertis.PLAY_TIRG;
				dispatchEvent(new AppEvent(AppEvent.SHOW_WINDOWS_LAYOUT,obj));
			}else{
				obj.show=false;
				obj.mediaModel=mediaModel;
				playMode=SuperAdvertis.PLAY_AUTO;
				dispatchEvent(new AppEvent(AppEvent.SHOW_WINDOWS_LAYOUT,obj));
			}
		}
		override public function mediaStop():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_STOP;
			_timer.stop();
		}
		
		protected function timerCompleteHandler(event:TimerEvent=null):void
		{
			if(playMode==SuperAdvertis.PLAY_AUTO){
				if(mediaModel.ID==MediaModel.WINDOWS && mediaModel.windowsCtrlSuperAdvertis){
					this.alpha=0;
					hide();
					if(mediaModel.windowsCtrlSuperAdvertis){
						mediaModel.windowsCtrlSuperAdvertis.nextMedia();
					}
				}else{
					mediaStop();
					this.dispatchEvent(new AppEvent(AppEvent.MEDIA_PLAY_END,this.mediaModel,"image"));
				}
			}
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			if(_moutimediaUrl==this.mediaModel.mediaUrl){
				_moutimediaUrl=this.mediaModel.mediaNetUrl;
				var urlRequest:URLRequest=new URLRequest(_moutimediaUrl);
				_loader.load(urlRequest);
			}else{
				_timer.stop();
				timerCompleteHandler();
				trace("loader_error:"+_moutimediaUrl+event.errorID);
			}
		}
		
		protected function loaderCompleteHandler(event:Event):void
		{
			loaderComplete();
			trace(mediaModel.mediaUrl,"加载完成");
			//var bitmapData:BitmapData = event.currentTarget.content.bitmapData as BitmapData;
			var bmp:Bitmap=event.currentTarget.content as Bitmap;
			bmp.smoothing=true;
			/*var scale:Number = Math.min(_moutimediaWidth/bmp.width ,_moutimediaHeight/bmp.height);
			bmp.scaleX = bmp.scaleY = bmp.scaleY*scale;
			bmp.x = (_moutimediaWidth-bmp.width)/2;
			bmp.y = (_moutimediaHeight-bmp.height)/2;*/
			bmp.width=_moutimediaWidth;
			bmp.height=_moutimediaHeight;
			if(_loader){_loading.close()};
		}
		override public function hide():void{
			if(_loader){
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loaderCompleteHandler);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				_loader.unloadAndStop()
			};
			_loader=null;
			_loading=null;
			if(_timer)_timer.removeEventListener(TimerEvent.TIMER_COMPLETE,timerCompleteHandler);
			if(_timer)_timer.stop();
			_timer=null;
			removeAll();
			trace(mediaModel.mediaUrl,"结束");
			_currentStatic=MediaAbstract.CURRENT_STATIC_WAIT;
		}
	}
}