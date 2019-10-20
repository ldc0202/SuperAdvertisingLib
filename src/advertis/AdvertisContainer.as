package advertis
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import advertis.multimedia.IFactory;
	import advertis.multimedia.IMedia;
	import advertis.multimedia.MediaAbstract;
	import advertis.multimedia.MediaModel;
	import advertis.multimedia.TransitionCtrl;
	import advertis.multimedia.media.ImageFactory;
	import advertis.multimedia.media.MediaImage;
	import advertis.multimedia.media.MediaStageVideo;
	import advertis.multimedia.media.MediaSubTitleText;
	import advertis.multimedia.media.MediaSwf;
	import advertis.multimedia.media.MediaText;
	import advertis.multimedia.media.MediaVideo;
	import advertis.multimedia.media.SwfFactory;
	import advertis.multimedia.media.TextFactory;
	import advertis.multimedia.media.VideoFactory;

	public class AdvertisContainer extends Sprite
	{
		private var _backgroundURL:String;
		private var _backgroundColor:uint;
		private var _advertisWidth:Number=10;
		private var _advertisHeight:Number=10;
		private var background:Sprite;
		private var advertisContainer:Sprite;
		private var _mask:Sprite;
		private var _playMode:String="auto";//ctrl
		private var _bgColorAlpha:Number;
		private var _mediaSubTitleText:MediaSubTitleText;
		private var transtion:TransitionCtrl;
		private var _currentMedia:MediaAbstract;
		public var transitionEndCallBack:Function;
		public function AdvertisContainer(w:Number,h:Number,bgColor:uint=0x000000,bgColorAlpha:Number=1,bgUrl:String="")
		{
			_advertisWidth=w;
			_advertisHeight=h;
			_bgColorAlpha=bgColorAlpha;
			background=new Sprite();
			this.addChild(background);
			backgroundColor=bgColor;
			backgroundURL=bgUrl;
			super();
			advertisContainer=new Sprite();
			_mask=drawRect();
			_mask.alpha=0.5;
			this.addChild(_mask);
			this.addChild(advertisContainer);
			advertisContainer.mask=_mask;
			transtion=new TransitionCtrl(advertisContainer,w,h);
			transtion.transitionEndCallBack=transitionEnd;
		}
		private function transitionEnd():void{
			if(transitionEndCallBack!=null){
				transitionEndCallBack();
			}
		}
		/**
		 * 推动模式(playMode="tirg")时使用此方法实时更新内容。
		 * @param modle=媒体数据；
		 */
		public function addAdvertis(media:MediaAbstract):void{
			media.playMode=playMode;
			_currentMedia=media;
			advertisContainer.addChild(DisplayObject(media));
			if(SuperAdvertis.USEHARDWAREACCELERATION=="0"){
				transtion.transitionIn(media.mediaModel.transtionNum);
			}else{
				var t:Boolean=SuperAdvertis.ARDWAREACCELERATION_ISUSED;
					//如果是视频就硬切
					if(_currentMedia.mediaModel.type==MediaModel.MOVIE_FLV || _currentMedia.mediaModel.type==MediaModel.MOVIE_MP4  || _currentMedia.mediaModel.type==MediaModel.MOVIE_F4V){
						_currentMedia.mediaPlay();
						//if(t){
						   transtion.end();
						//}
					}else{
						transtion.transitionIn(media.mediaModel.transtionNum);
					}
				
			}
			
			//transtion.transitionIn(Math.floor(6*Math.random()));//2,3,6,8,9
			//transtion.transitionIn(10);
		}
		public function createMedia(modle:MediaModel):MediaAbstract{
			var f:IFactory;
			var media:MediaAbstract;
			if(modle.type==MediaModel.IMAGE_JPG || modle.type==MediaModel.IMAGE_PNG || modle.type==MediaModel.IMAGE_GIF || modle.type==MediaModel.IMAGE_JPEG || modle.type==MediaModel.IMAGE_JPE || modle.type==MediaModel.IMAGE_PNS){
				f=new ImageFactory();
				media=MediaImage(f.factory(modle));
			}
			if(modle.type==MediaModel.MOVIE_SWF){
				f=new SwfFactory();
				media=MediaSwf(f.factory(modle));
			}
			if(modle.type==MediaModel.MOVIE_FLV || modle.type==MediaModel.MOVIE_MP4  || modle.type==MediaModel.MOVIE_F4V){
				f=new VideoFactory();
				media=MediaVideo(f.factory(modle));
				//media=MediaStageVideo(f.factory(modle));
			}
			if(modle.type!=MediaModel.TEXT && _mediaSubTitleText && modle.textModel.behavior!=MediaModel.TEXT_BEHAVIOR_SUBTITLE){
				_mediaSubTitleText=null;
			}
			if(modle.type.toLocaleLowerCase()==MediaModel.TEXT.toLocaleLowerCase()){
				if(modle.textModel && modle.textModel.behavior==MediaModel.TEXT_BEHAVIOR_SUBTITLE){
					//作用：当前为弹屏滚动文字状态时不新建MediaSubTitleText，只增加内部滚动文本
					/*if(_mediaSubTitleText){
						_mediaSubTitleText.addMedia(modle);
					}else{
						f=new TextFactory();
						media=_mediaSubTitleText=MediaSubTitleText(TextFactory(f).factorySubTitle(modle));
					}*/
					//20180314改成都重新创建。
						f=new TextFactory();
						media=_mediaSubTitleText=MediaSubTitleText(TextFactory(f).factorySubTitle(modle));
					
				}else{
					f=new TextFactory();
					media=MediaText(f.factory(modle));
				}
			}else{
				//trace(modle.mediaUrl);
			}
			if(!media){
					//throw new Error("不支持此数据类型："+modle.type); 
				trace("不支持此数据类型："+modle.type);
			}
			return media;
		}
		
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
			background.addChild(drawRect());
			
		}
		private function drawRect():Sprite{
			var rec:Sprite=new Sprite();
			rec.graphics.clear();
			rec.graphics.beginFill(_backgroundColor,_bgColorAlpha);
			rec.graphics.drawRect(0,0,_advertisWidth,_advertisHeight);
			rec.graphics.endFill();
			return rec;
		}
		private function addImageBackground(imgURL:String):void
		{
			var onImgLoadComplete:Function = function(e:Event):void
			{
				var bitmapData:BitmapData = e.currentTarget.content.bitmapData as BitmapData;
				var bitmap:Bitmap=new Bitmap(bitmapData);
				bitmap.width=_advertisWidth; 
				bitmap.scaleY=bitmap.scaleX; 
				if (bitmap.height<_advertisHeight) { 
					bitmap.height=_advertisHeight; 
					bitmap.scaleX=bitmap.scaleY; 
				} 
				background.addChild(bitmap);
			}
			var onImgLoadError:Function = function(e:IOErrorEvent):void
			{
				 trace("addBackground failed! URL:",imgURL,e);
			}
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onImgLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onImgLoadError);
			loader.load(new URLRequest(imgURL));
		}
		public function set playMode(value:String):void
		{
			for(var i:int=0;i<advertisContainer.numChildren;i++){
				IMedia(advertisContainer.getChildAt(i)).playMode=value;
			}
			_playMode = value;
		}
		public function get playMode():String
		{
			return _playMode;
		}
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}

		public function set backgroundURL(url:String):void
		{
			// background.source=url;
			if(url!=null){
				addImageBackground(url);
			}
			 _backgroundURL=url
		}
		public function get backgroundURL():String
		{
			return _backgroundURL;
		}
		public function unLoadAndStop():void{
			for(var i:int=0;i<advertisContainer.numChildren;i++) 
			{
				var ob:IMedia=advertisContainer.getChildAt(i) as IMedia;
				ob.hide();
			}
			advertisContainer.removeChildren();
		}
	}
}