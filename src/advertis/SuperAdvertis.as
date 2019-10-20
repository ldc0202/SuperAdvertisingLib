package advertis
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.setTimeout;
	
	import advertis.multimedia.MediaAbstract;
	import advertis.multimedia.MediaModel;
	import advertis.multimedia.media.MediaSubTitleText;
	
	import advertisData.IadvertisData;
	
	import densioAdvertis.AdvertisAbstract;
	
	import events.AppEvent;

	public class SuperAdvertis extends AdvertisAbstract
	{
		public static const PLAY_AUTO:String="auto";//自动播放模式
		public static const PLAY_TIRG:String="tirg";//推动模式
		public static var USEHARDWAREACCELERATION:String="0";//可用硬件进行硬件加速时是否进行硬件加速"1"为启用“0”为不使用
		public static var ARDWAREACCELERATION_ISUSED:Boolean=false;//是否已使用过硬 件加速（能用硬件加速）
		private var _advertisContainer:AdvertisContainer;
		private var mediaModel_arr:Array=new Array();
		private var currentAdvertis:int=0;
		private var _playMode:String=SuperAdvertis.PLAY_AUTO;//tirg
		public var modifyTime:String;
		public var layoutID:String;
		private var mouseDownX:Number=0;
		private var _preloadingMode:Boolean=false;
		private var _currentPlayMedia:MediaAbstract;
		/**
		 * 当前布局队列是否播完并在等待中。
		 * */
		public var playEndAndWait:Boolean=false;
		public function SuperAdvertis(advertisD:IadvertisData)
		{
			super(advertisD);
			_advertisContainer=new AdvertisContainer(advertisD.initWidth,advertisD.initHeight,advertisD.backgroundColor,advertisD.bgColorAlpha,advertisD.backgroundURL);
			addChild(_advertisContainer);
			_advertisContainer.transitionEndCallBack=transitionEnd;
			for each (var i:MediaModel in advertisD.advertisModels) 
			{
				if(i.type==MediaModel.TEXT){playEndAndWait=true};//因为是文字的时间不用算次数是循环的。一开始就标记为已完成播放以便节目统计切换。
				var medi:MediaAbstract=_advertisContainer.createMedia(i);
				if(medi){
					mediaModel_arr.push(medi);
				}
			}
			//如果只有一条数据，就加多一条一样的。以便预加载和转场
			if(mediaModel_arr.length==1 && i.ID!=MediaModel.WINDOWS){
				var medi1:MediaAbstract=_advertisContainer.createMedia(i);
				if(medi1){
					mediaModel_arr.push(medi1);
				}
			}
			if(mediaModel_arr.length>0){
				currentAdvertis=-1;
				setTimeout(timerHandler,100);
			}else{
				playEndAndWait=true;
			}
			_advertisContainer.addEventListener(AppEvent.MEDIA_PLAY_END,mediaPlayEndHandler);
			//_advertisContainer.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			//_advertisContainer.addEventListener(MouseEvent.MOUSE_UP,mouseHandler);
		}
		/**
		 * 是否启用预加载模式：为true时在当前媒本播放时后面最多2个媒体开始初始化并载入数据。
		 */
		public function get preloadingMode():Boolean
		{
			return _preloadingMode;
		}

		public function set preloadingMode(value:Boolean):void
		{
			_preloadingMode = value;
		}

		protected function mouseHandler(event:MouseEvent):void
		{
			if(event.type=="mouseDown"){
				mouseDownX=_advertisContainer.mouseX;
			}else{
				var dist:Number=_advertisContainer.mouseX-mouseDownX;
			    if(Math.abs(dist)>5){
					dist>0 ? previousMedia() : nextMedia();
				}
			}
		}
		override public function set advertisModels(value:Object):void{
			super.advertisModels=value;
			mediaModel_arr=[];
			for each (var i:MediaModel in value) 
			{
				var medi:MediaAbstract=_advertisContainer.createMedia(i);
				if(medi){
					mediaModel_arr.push(medi);
				}
			}
			//如果只有一条数据，就加多一条一样的。以便预加载和转场
			if(mediaModel_arr.length==1){
				var medi1:MediaAbstract=_advertisContainer.createMedia(i);
				if(medi1){
					mediaModel_arr.push(medi1);
				}
			}
			if(mediaModel_arr.length>0){
				currentAdvertis=-1;
				timerHandler();
			}
		}
		public function createMedia(mediaModel:MediaModel):MediaAbstract{
			return _advertisContainer.createMedia(mediaModel);
		}
		/**
		 * 转场完后让当前的媒体开始播放
		 */
		private function transitionEnd():void{
			if(_currentPlayMedia){
				trace("当前媒体状态",_currentPlayMedia.currentStatic,_currentPlayMedia.mediaModel.mediaUrl);
				if(_currentPlayMedia.currentStatic==MediaAbstract.CURRENT_STATIC_WAIT){
					_currentPlayMedia.startLoad();
				};
				//如果只有两个媒体在转场完成时前一个已被清除这里让它加载。
				if(mediaModel_arr.length<=2 && preloadingMode){
					for each (var i:MediaAbstract in mediaModel_arr) 
					{
						if(i!=_currentPlayMedia && i.currentStatic!=MediaAbstract.CURRENT_STATIC_LOADING){
							i.startLoad();
						}
					}
					
				}
				/*if(_currentPlayMedia.mediaModel.type!=MediaModel.MOVIE_F4V && _currentPlayMedia.mediaModel.type!=MediaModel.MOVIE_FLV && _currentPlayMedia.mediaModel.type!=MediaModel.MOVIE_MP4){
					_currentPlayMedia.mediaPlay();
				}*/
				//if(_currentPlayMedia.mediaModel.type!=MediaModel.TEXT){
					_currentPlayMedia.mediaPlay()
				//};
			};
		}
		/**
		 * 推动模式(playMode="tirg")时使用此方法实时更新内容。
		 * @param modle=媒体数据；
		 */
		public function addAdvertis(media:MediaAbstract):void{
			if(media){
				_currentPlayMedia=media;
				_advertisContainer.addAdvertis(media);
				if(!preloadingMode){
					//不是预加载模式时让当前媒体开始加载。
					media.hide();
					media.startLoad();
				}else if(media.mediaModel.type==MediaModel.MOVIE_F4V || media.mediaModel.type==MediaModel.MOVIE_FLV || media.mediaModel.type==MediaModel.MOVIE_MP4){
						if(media.currentStatic==MediaAbstract.CURRENT_STATIC_WAIT){
							media.startLoad();
						};
						//media.mediaPlay();//为什么要在放入显示列表时就播放？因为视频在转场未播放时没有画面致转场很突然。尽管我在开如播放前是暂停的。。。。无解。。。
				}
			};
		}
		
		private function preloadingHadler(num:int):void{
			if(mediaModel_arr.length<2){
				return
			};
			//后面还有预加长度时
			if(currentAdvertis+num<mediaModel_arr.length){
				chang(currentAdvertis+1,currentAdvertis+num);
				//在最后一个时在数组前面让指定个数的媒体加载
			}else if(currentAdvertis==mediaModel_arr.length-1){
				chang(0,num);
				//后面长度不够时
			}else{
				chang(currentAdvertis+1,currentAdvertis+num);
				var temp:int=currentAdvertis+num-(mediaModel_arr.length-1);
				chang(0,temp);
			}
			function chang(a:int,b:int):void{
				for (var i:int = a; i <= b; i++) 
				{
					if(i<mediaModel_arr.length){
						var m:MediaAbstract=mediaModel_arr[i] as MediaAbstract;
						if(m.currentStatic==MediaAbstract.CURRENT_STATIC_WAIT && m.currentStatic!=MediaAbstract.CURRENT_STATIC_LOADING){
							m.startLoad();
							//trace(m.mediaModel.mediaUrl);
						};
					};
				};
			}
		}
		protected function mediaPlayEndHandler(event:Event=null):void
		{
			timerHandler();
			
		}
		/**
		 * 只释放布局播放列表
		*/
		public function unLoadAndStop():void{
			_advertisContainer.unLoadAndStop();
			mediaModel_arr=[];
		}
		/**
		 * 释放布局和播放列表
		 */
		public function dispose():void{
			unLoadAndStop();
			if(_advertisContainer){
				_advertisContainer.removeEventListener(AppEvent.MEDIA_PLAY_END,mediaPlayEndHandler);
				removeChild(_advertisContainer);
				_advertisContainer=null;
			}
		}
		protected function timerHandler(event:TimerEvent=null):void
		{
			var m:MediaModel=mediaModel_arr[currentAdvertis] ? mediaModel_arr[currentAdvertis].mediaModel : null;
			if(currentAdvertis>-1 && mediaModel_arr.length==1 && m && m.type!=MediaModel.MOVIE_F4V && m.type!=MediaModel.MOVIE_FLV && m.type!=MediaModel.MOVIE_SWF && m.type!=MediaModel.MOVIE_MP4 && m.type!=MediaModel.TEXT.toLocaleLowerCase()){
				var media:MediaAbstract=mediaModel_arr[currentAdvertis];
				if(media){media.startLoad();};
				playEndAndWait=true;
				this.dispatchEvent(new AppEvent(AppEvent.LAYOUT_PLAY_END,this,"布局播放完成"));
				currentAdvertis=0;
				return
			};//只有一条数据而且不是第一次播就不切换了。
			if(currentAdvertis>=mediaModel_arr.length-1){
				//当前布局已经播完发送事件给节目控制，从而判断是不是所有布局队列是否播完。播完就开始播下一节目！
				playEndAndWait=true;
				this.dispatchEvent(new AppEvent(AppEvent.LAYOUT_PLAY_END,this,"布局播放完成"));
				//为什么放在这里呢因为弹窗或说在推送模式时只能用index来判断当前布局是不是播完了
				currentAdvertis=0;
			}else{
				currentAdvertis++;
			}
			if(preloadingMode){
				preloadingHadler(1);
			}
			addAdvertis(mediaModel_arr[currentAdvertis]);
		}
		public function nextMedia():void{
			//_advertisContainer.unLoadAndStop();
			timerHandler(null);
		}
		public function play():void{
			var currentMedia:MediaAbstract=mediaModel_arr[currentAdvertis];
			if(currentMedia && currentMedia.mediaModel.type!=MediaModel.TEXT){currentMedia.mediaPlay()};
		}
		public function pause():void{
			var currentMedia:MediaAbstract=mediaModel_arr[currentAdvertis];
			if(currentMedia){currentMedia.mediaStop()};
		}
		public function previousMedia():void{
			//_advertisContainer.unLoadAndStop();
			if(currentAdvertis>0 && mediaModel_arr.length){
				currentAdvertis--;
				addAdvertis(mediaModel_arr[currentAdvertis]);
			}else if(mediaModel_arr.length){
				currentAdvertis= mediaModel_arr.length-1;
				addAdvertis(mediaModel_arr[currentAdvertis]);
			}
		}
		override public function set playMode(value:String):void
		{
			_advertisContainer.playMode=value;
			_playMode = value;
		}
		override public function get playMode():String
		{
			return _playMode;
		}
	}
}