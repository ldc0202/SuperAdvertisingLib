package advertis.multimedia.media
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.media.VideoStatus;
	import flash.net.FileReference;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.graphics.codec.PNGEncoder;
	
	import advertis.SuperAdvertis;
	import advertis.multimedia.IMedia;
	import advertis.multimedia.MediaAbstract;
	import advertis.multimedia.MediaModel;
	
	import events.AppEvent;
	
	public class MediaStageVideo extends MediaAbstract implements IMedia
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
		private var sv:StageVideo;       
		private var stageVideoAvailability:Boolean=false;
		private var _this:MediaStageVideo;
		public static var usedStageVideos:Array=[];
		public function MediaStageVideo(mediaModel:Object)
		{
			super();
			addMedia(MediaModel(mediaModel));
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage); 
			drawBg(false);
			_this=this;
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
			//hide();
			isFirstStatic=true;
			_currentStatic=MediaAbstract.CURRENT_STATIC_LOADING;
			
		}
		override public function mediaPlay():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_PLAYING;
			if(ns==null){
				toggleStageVideo(false);
			}
			if(ns){
				//ns.seek(0);
				//ns.pause();
				ns.resume();
			}
			
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
		private function onAddedToStage(event:Event):void 
		{ 
			/*addChild(_loading=new Loading(_moutimediaWidth,_moutimediaHeight));
			if(!stageVideoAvailability && !video){
				video=new Video(this.mediaModel.mediaWidth,this.mediaModel.mediaHeight);
				video.smoothing=true;
				this.addChild(video);
			}else{
				toggleStageVideo(stageVideoAvailability);
			}*/
			this.stage.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage); 
		   this.stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState)
		}
		private function onStageVideoState(event:StageVideoAvailabilityEvent):void 
		{     
			// Detect if StageVideo is available and decide what to do in toggleStageVideo 
			//stageVideoAvailability=event.availability == StageVideoAvailability.AVAILABLE
			//if(this.stage){this.stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState)};
			this.stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState)
			toggleStageVideo(event.availability == StageVideoAvailability.AVAILABLE); 
		} 
		private function toggleStageVideo(on:Boolean):void 
		{ 
			stageVideoAvailability=on;
			startVid();
			if(stageVideoAvailability && SuperAdvertis.USEHARDWAREACCELERATION=="1"){
				if(video){
					video.clear();
					video.attachNetStream(null);
					this.removeChild(video);
					video=null;
				}
				if ( sv == null && stage )       
				{       
					// retrieve the first StageVideo object       
					//sv = stage.stageVideos[stageVideosNum];
					bgInOut();
					if(MediaStageVideo.usedStageVideos.length==0 && sv==null){
						sv = stage.stageVideos[0]
						MediaStageVideo.usedStageVideos.push(sv);
					}else{
						for (var i:int = 0; i < stage.stageVideos.length; i++) 
						{
							if(MediaStageVideo.usedStageVideos.indexOf(stage.stageVideos[i])==-1 && sv==null){
								sv=stage.stageVideos[i];
								MediaStageVideo.usedStageVideos.push(sv);
							}
						}
					}
					sv.attachNetStream(ns); 
					sv.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange); 
					//sv.dispatchEvent(new StageVideoEvent(StageVideoEvent.RENDER_STATE));
					this.dispatchEvent(new AppEvent(AppEvent.STAGEVIDEO_PLAYING,true,"视频使用了硬件加速！"));
					SuperAdvertis.ARDWAREACCELERATION_ISUSED=true;
					
					trace("stagevideo");
				}
				
			}else{
				addChild(_loading=new Loading(_moutimediaWidth,_moutimediaHeight));
				_loading.visible=false;
				if(!video){
					video=new Video(this.mediaModel.mediaWidth,this.mediaModel.mediaHeight);
					video.smoothing=true;
					this.addChild(video);
					if(video){video.attachNetStream(ns)};
				}
				this.dispatchEvent(new AppEvent(AppEvent.STAGEVIDEO_PLAYING,false,"没有使用视频硬件加速！"));
				SuperAdvertis.ARDWAREACCELERATION_ISUSED=false;
			}
			if(_currentStatic==MediaAbstract.CURRENT_STATIC_PLAYING){
				//mediaPlay();加了发达SHOW_WINDOWS_LAYOUT事件弹窗。不能加加了会进入死循环。
				_currentStatic=MediaAbstract.CURRENT_STATIC_PLAYING;
			}else{
				_currentStatic=MediaAbstract.CURRENT_STATIC_LOADING
			}
			trace("可硬件视频加速：",on);
		}
		private function bgInOut():void{
			var sp:Sprite=new Sprite();
			sp.graphics.clear();
			sp.graphics.beginFill(0);
			sp.graphics.drawRect(0,0,mediaModel.mediaWidth,mediaModel.mediaHeight);
			sp.graphics.endFill();
			_this.addChild(sp);
			TweenLite.to(sp,2,{alpha:0,onComplete:f})
			//setTimeout(function():void{TweenLite.to(sp,1,{alpha:0,onComplete:f})},500);
			function f():void{
				_this.removeChild(sp);
			}
		}
		private function faceImage(dis:DisplayObject):Bitmap{
			var wScale:Number=_moutimediaWidth/_streamWidth;
			var hScale:Number=_moutimediaHeight/_streamHeight;
			var W:Number;
			var H:Number;
			if(wScale<hScale){
				W = _moutimediaWidth;
				H = _streamHeight*wScale;
			}else{
				H = _moutimediaHeight;
				W = _streamWidth*hScale;
			}
			var bitmapdata:BitmapData=new BitmapData(int(W),int(H),true,0);
			var rOffset:Number =  0;
			var gOffset:Number =  0;
			var bOffset:Number =  0;
			var aOffset:Number =  0;
			
			var p:Point=_this.parent.localToGlobal(new Point(_this.parent.x,_this.parent.y));
			var pointForWH:Point=_this.parent.localToGlobal(new Point(_this.parent.x+W,_this.parent.y+H));
			//sv.zoom=new Point(8,8);
			//var rc:Rectangle = computeVideoRect(p.x,p.y,pointForWH.x-p.x,pointForWH.y-p.y);
			
			var colorTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, rOffset, gOffset, bOffset, aOffset);
			bitmapdata.draw(dis,new Matrix(1,0,0,1,-424,-163),null,null,null,true);
			var bit:Bitmap=new Bitmap(bitmapdata,"auto",true);
			
			//bitmapdata.applyFilter(bitmapdata,new Rectangle(0,0,3840,2160),new Point(0,0));
			
			var pngenc:PNGEncoder = new PNGEncoder();
			//var pngenc:JPEGEncoder=new JPEGEncoder(80);//用于编码位图
			var imgByteArray:ByteArray = pngenc.encode(bitmapdata);
			//保存位图到本地
			var file:FileReference = new FileReference();
			file.save(imgByteArray,"vini123.png");
			return bit;
		}
		override public function mediaStop():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_STOP;
			if(ns){ns.pause()};
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
					if(_loading){_loading.visible=false};
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
					if(_loading){_loading.visible=false};
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
					if(_loading){_loading.visible=false};
					trace("buffer flush");
					break;
				case "NetStream.Pause.Notify" :
					//_loading.visible=true;
					trace("pause notify");
					break;
				case "NetStream.Unpause.Notify" :
					if(_loading){_loading.visible=false};
					trace("unpause notify");
					break;
			}
			
		}
		override public function loaderComplete(event:Event=null):void
		{
			_currentStatic=MediaAbstract.CURRENT_STATIC_READY;
			if(stageVideoAvailability){
				//faceImage(DisplayObject(this.stage));
			}
			
		}
		private function connectStream():void{
			if(!ns){ns = new NetStream(nc)};
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			metaDataObj.onMetaData = this.onMetaData;
			ns.client = metaDataObj;
			if(video){video.attachNetStream(ns)};
			ns.play(currentUrl);
			if(_currentStatic!=MediaAbstract.CURRENT_STATIC_PLAYING){
				ns.pause();
			}
			if(_loading){_loading.visible=false};
		}
		private function stageVideoStateChange(event:StageVideoEvent):void       
		{          
			var status:String = event.status;    
			if(_this.parent){resize()};       
		}
		private function resize ():void       
		{   
			var wScale:Number=_moutimediaWidth/_streamWidth;
			var hScale:Number=_moutimediaHeight/_streamHeight;
			var W:Number;
			var H:Number;
				/*if(wScale<hScale){
					W = _moutimediaWidth;
					H = _streamHeight*wScale;
				}else{
					H = _moutimediaHeight;
					W = _streamWidth*hScale;
				}*/
			W = _moutimediaWidth;
			H = _moutimediaHeight;
			var p:Point=_this.parent.localToGlobal(new Point(_this.parent.x,_this.parent.y));
			var pointForWH:Point=_this.parent.localToGlobal(new Point(_this.parent.x+W,_this.parent.y+H));
			//sv.zoom=new Point(8,8);
			var rc:Rectangle = computeVideoRect(p.x,p.y,pointForWH.x-p.x,pointForWH.y-p.y);       
			if(sv){
				sv.viewPort = rc;
				//sv.;	
				//sv.videoHeight;
			};
			//sv.pan=_this.parent.localToGlobal(new Point(_this.parent.x,_this.parent.y));
		}
		private function computeVideoRect(objX:Number,objY:Number,w:Number,h:Number):Rectangle{
			var rc:Rectangle=new Rectangle(objX,objY,w,h);
			return rc;
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
					//hide();
					if(mediaModel.ID==MediaModel.WINDOWS && mediaModel.windowsCtrlSuperAdvertis){
						this.alpha=0;
						hide();
						mediaModel.windowsCtrlSuperAdvertis.nextMedia();
					}else{
						this.dispatchEvent(new AppEvent(AppEvent.MEDIA_PLAY_END,this.mediaModel,"video"));
					}
				}else if(playMode==SuperAdvertis.PLAY_TIRG){
					ns.pause();
					ns.seek(0);
					ns.resume();
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
			//setTimeout(function():void{faceImage(DisplayObject(_this.stage))},3000);
			
			var wScale:Number=_moutimediaWidth/_streamWidth;
			var hScale:Number=_moutimediaHeight/_streamHeight;
			/*if(video){
				if(wScale<hScale){
					video.width = _moutimediaWidth;
					video.height = _streamHeight*wScale;
				}else{
					video.height = _moutimediaHeight;
					video.width = _streamWidth*hScale;
				}
				video.x = (_moutimediaWidth-video.width)/2;
				video.y = (_moutimediaHeight-video.height)/2;
			}*/
			if(video){
			video.width = _moutimediaWidth;
			video.height = _moutimediaHeight;
			}
			/*for each(var prop:Object in obj)
			{
				trace(obj[i] + "  :  " + prop);
				i++;
			}*/
			//trace(obj.duration+" "+obj.framerate+" "+obj.bitrate);
		}
		
		override public function hide():void{
			/*if(mediaModel.ID==MediaModel.WINDOWS && _currentStatic==MediaAbstract.CURRENT_STATIC_PLAYING){
				return;
			}*/
			if(MediaStageVideo.usedStageVideos.indexOf(sv)!=-1){
				MediaStageVideo.usedStageVideos.splice(MediaStageVideo.usedStageVideos.indexOf(sv),1);
			}
			if(sv){
				sv.attachNetStream(null)
				sv=null;
			};
			back_clickHandler();
			removeAll();
			_currentStatic=MediaAbstract.CURRENT_STATIC_WAIT;
		}
	}
}