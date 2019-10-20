package advertis.multimedia.media
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import advertis.SuperAdvertis;
	import advertis.multimedia.IMedia;
	import advertis.multimedia.MediaAbstract;
	import advertis.multimedia.MediaModel;
	
	import events.AppEvent;
	
	public class MediaVideo extends MediaAbstract implements IMedia
	{
		private var _moutimediaWidth:Number;
		private var _moutimediaHeight:Number;
		private var _moutimediaUrl:String
		private var _type:String="flv";
		
		private var video:Video;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var metaDataObj:Object = {};
		private var currentUrl:String;
		private var shichang:Number;
		private var _streamWidth:Number;
		private var _streamHeight:Number;
		private var _frequency:uint;
		private var _currentFrequency:uint=1;
		private var _loading:Loading;
		public function MediaVideo(mediaModel:Object)
		{
			super();
			addMedia(MediaModel(mediaModel));
		}
		override public function addMedia(mediaM:MediaModel):void
		{
			super.addMedia(mediaM);
			back_clickHandler();
			this.mediaModel=mediaM;
			_moutimediaWidth=mediaM.mediaWidth;
			_moutimediaHeight=mediaM.mediaHeight;
			_frequency=mediaM.frequency;
			currentUrl=mediaM.mediaUrl;
		}
		
		override public function startLoad():void{
			isFirstStatic=true;
			_currentStatic=MediaAbstract.CURRENT_STATIC_LOADING;
			video=new Video(this.mediaModel.mediaWidth,this.mediaModel.mediaHeight);
			video.smoothing=true;
			this.addChild(video);
			addChild(_loading=new Loading(_moutimediaWidth,_moutimediaHeight));
			startVid();
		}
		override public function mediaPlay():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_PLAYING;
			if(ns){
				//ns.seek(0);
				//ns.pause();
				ns.resume();
			};
		}
		override public function mediaStop():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_STOP;
			if(ns){
				ns.pause();
			};
		}
		protected function back_clickHandler(event:MouseEvent=null):void
		{
			/*player.stop();
			player.source="";*/
			if(ns){
				ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				ns.pause();
				ns.close();
				ns.dispose();
			}
			if(nc){
				nc.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				nc.close();
				nc=null;
			}
			if(video){
				video.clear();
				video=null;
			}
			if(_loading){
				_loading.close();
				_loading=null;
			}
			removeAll();
		}
		private function startVid():void {
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			nc.connect(null);
			
		}
		private var isFirstStatic:Boolean=true;
		private function  netStatusHandler(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				case "NetStream.Play.StreamNotFound":
					_currentFrequency=_frequency;
					trace("Stream not found: " + currentUrl);
					endHandler();
					
					break;
				case "NetStream.Play.Stop" :
					_loading.visible=false;
					endHandler();
					//this.dispatchEvent(new Event("flv complete"));
					trace("stop");
					//container.dispatchEvent(new MyEvent(MyEvent.FLV_FINISHED));
					break;
				case "NetStream.Seek.Notify" :
					trace("seek successed");
					//container.dispatchEvent(new MyEvent(MyEvent.SEEK_FINISHED));
					break;
				case "NetStream.Seek.Failed" :
					trace("seek failed");
					break;
				case "NetStream.Buffer.Empty" :
					if(ns.time<shichang-0.5){
						//_loading.visible=true;
					}
					trace("buffer empty");
					break;
				case "NetStream.Buffer.Full" :
					_loading.visible=false;
					trace("buffer full");
					if(isFirstStatic){
						isFirstStatic=false;
						/*if(currentStatic!= MediaAbstract.CURRENT_STATIC_PLAYING && ns){
							ns.inBufferSeek=false;
							ns.seek(0);
							ns.pause();
						};*/
						loaderComplete();
					}
					break;
				case "NetStream.Buffer.Flush" :
					_loading.visible=false;
					trace("buffer flush");
					break;
				case "NetStream.Pause.Notify" :
					//_loading.visible=true;
					trace("pause notify");
					break;
				case "NetStream.Unpause.Notify" :
					_loading.visible=false;
					trace("unpause notify");
					break;
			}
			
		}
		private function connectStream():void{
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			metaDataObj.onMetaData = this.onMetaData;
			ns.client = metaDataObj;
			video.attachNetStream(ns);
			ns.play(currentUrl);
			ns.pause();
			_loading.visible=false;
		}
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			
				trace("securityErrorHandler: " + event);
			
		}
		private var enterFrameAble:Boolean=true;
	
		private function endHandler():void{
			/*if(currentUrl==this.mediaModel.mediaUrl){
				currentUrl=this.mediaModel.mediaNetUrl;
				trace(currentUrl);
				ns.play(currentUrl);
			}else{*/
			    ns.pause();
				if(_currentFrequency<_frequency){
					ns.pause();
					ns.seek(0);
					ns.resume();
					_currentFrequency++;
				}else if(playMode==SuperAdvertis.PLAY_AUTO){
					hide();
					this.dispatchEvent(new AppEvent(AppEvent.MEDIA_PLAY_END,this.mediaModel,"video"));
				}
			//}
		}
		private function onMetaData(obj:Object):void {
			
			var i:int = 0;
			if(obj.duration){
				shichang=Number(obj.duration);
			}
			_streamWidth=Number(obj.width);
			_streamHeight=Number(obj.height);
			
			var wScale:Number=_moutimediaWidth/_streamWidth;
			var hScale:Number=_moutimediaHeight/_streamHeight;
			if(wScale<hScale){
				video.width = _moutimediaWidth;
				video.height = _streamHeight*wScale;
			}else{
				video.height = _moutimediaHeight;
				video.width = _streamWidth*hScale;
			}
			
			video.x = (_moutimediaWidth-video.width)/2;
			video.y = (_moutimediaHeight-video.height)/2;
			/*for each(var prop:Object in obj)
			{
				trace(obj[i] + "  :  " + prop);
				i++;
			}*/
			//trace(obj.duration+" "+obj.framerate+" "+obj.bitrate);
		}
		
		override public function hide():void{
			back_clickHandler();
			removeAll();
			_currentStatic=MediaAbstract.CURRENT_STATIC_WAIT;
		}
	}
}