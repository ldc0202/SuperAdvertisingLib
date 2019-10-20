package advertis.multimedia.media
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import advertis.SuperAdvertis;
	import advertis.multimedia.IMedia;
	import advertis.multimedia.MediaAbstract;
	import advertis.multimedia.MediaModel;
	
	import events.AppEvent;
	
	
	public class MediaSwf extends MediaAbstract implements IMedia
	{
		private var _moutimediaWidth:Number;
		private var _moutimediaHeight:Number;
		private var _moutimediaUrl:String
		private var _loader:Loader;
		private var _type:String="swf";
		private var swf:MovieClip;
		private var _loading:Loading;
		private var _frequency:uint;
		private var _currentFrequency:uint=1;
		public function MediaSwf(mediaModel:Object)
		{
			super();
			addMedia(MediaModel(mediaModel));
		}
		override public function addMedia(mediaM:MediaModel):void
		{
			this.mediaModel=mediaM;
			_moutimediaWidth=mediaM.mediaWidth;
			_moutimediaHeight=mediaM.mediaHeight;
			_moutimediaUrl=mediaM.mediaUrl;
			_frequency=mediaM.frequency;
			_type=mediaM.type;
		}
		override public function startLoad():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_LOADING;
			_loader=new Loader();
			addChild(_loading=new Loading(_moutimediaWidth,_moutimediaHeight));
			addChild(_loader);
			var urlRequest:URLRequest=new URLRequest(_moutimediaUrl);
			_loader.load(urlRequest);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
		}
		override public function mediaPlay():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_PLAYING;
			if(swf){
				swf.gotoAndPlay(1);
			}
		}
		override public function mediaStop():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_STOP;
			if(swf){
				swf.stop();
			}
		}
		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			if(_moutimediaUrl==this.mediaModel.mediaUrl){
				_moutimediaUrl=this.mediaModel.mediaNetUrl;
				var urlRequest:URLRequest=new URLRequest(_moutimediaUrl);
				_loader.load(urlRequest);
			}else{
				_currentFrequency=_frequency;
				endHandler();
				trace("loader:"+_moutimediaUrl+event.errorID);
			}
		}
		protected function loaderCompleteHandler(event:Event):void
		{
			loaderComplete();
			//var bitmapData:BitmapData = event.currentTarget.content.bitmapData as BitmapData;
			swf=event.currentTarget.content as MovieClip;
			var scale:Number = Math.min(_moutimediaWidth/swf.width ,_moutimediaHeight/swf.height);
			swf.scaleX = swf.scaleY = swf.scaleY*scale;
			swf.x = (_moutimediaWidth-swf.width)/2;
			swf.y = (_moutimediaHeight-swf.height)/2;
			swf.gotoAndStop(1);
			swf.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			_loading.close();
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			if(swf.currentFrame==swf.totalFrames){
				if(_currentFrequency<_frequency){
					swf.gotoAndPlay(1);
					_currentFrequency++;
				}else{
					swf.stop();
					swf.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
					endHandler();
				}
			}
		}
		private function endHandler():void{
			if(playMode==SuperAdvertis.PLAY_AUTO){
				this.dispatchEvent(new AppEvent(AppEvent.MEDIA_PLAY_END,this.mediaModel,"swf"));
			}
		}
		
		override public function hide():void{
			if(swf){swf.removeEventListener(Event.ENTER_FRAME,enterFrameHandler)};
			_loader.unloadAndStop();
			removeAll();
			_currentStatic=MediaAbstract.CURRENT_STATIC_WAIT;
		}
	}
}