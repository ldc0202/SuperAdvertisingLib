package advertis.multimedia.media
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import advertis.SuperAdvertis;
	import advertis.multimedia.IMedia;
	import advertis.multimedia.MediaAbstract;
	import advertis.multimedia.MediaModel;
	
	import events.AppEvent;
	
	public class MediaText extends MediaAbstract implements IMedia
	{
		private var _moutimediaWidth:Number;
		private var _moutimediaHeight:Number;
		private var _moutimediaUrl:String
		private var _type:String="text";
		private var _timer:Timer;
		private var _residenceTime:Number;
		private var _loading:Loading;
		private var _frequency:uint;
		/**
		 * 静态文字如标题，字幕(要与播放的内容同步)
		 * */
		public function MediaText(mediaModel:Object)
		{
			super();
			_currentStatic=MediaAbstract.CURRENT_STATIC_READY;
			addMedia(MediaModel(mediaModel));
		}
		
		
		override public function addMedia(mediaM:MediaModel):void{
			this.mediaModel=mediaM;
		}
		override public function startLoad():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_LOADING;
		}
		override public function mediaPlay():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_PLAYING;
			createText();
			if(_timer){_timer.start()};
		}
		override public function mediaStop():void{
			_currentStatic=MediaAbstract.CURRENT_STATIC_STOP;
			if(_timer){_timer.stop()};
		}
		private var  _textField:TextField;
		private var newFormat:TextFormat = new TextFormat();
		private function createText():void{
			
			_moutimediaWidth=this.mediaModel.mediaWidth;
			_moutimediaHeight=this.mediaModel.mediaHeight;
			_moutimediaUrl=this.mediaModel.mediaUrl;
			_frequency=this.mediaModel.frequency;
			_type=this.mediaModel.type;
			_residenceTime=this.mediaModel.residenceTime;
			_timer=new Timer(_residenceTime,_frequency);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,timerCompleteHandler);
			
			var textSprite:Sprite=new Sprite();
			textSprite.filters=[];;
			_textField = new TextField();
			textSprite.addChild(_textField);
			_textField.type=TextFieldType.DYNAMIC;
			_textField.width = this.mediaModel.mediaWidth-20;
			if(this.mediaModel.textModel && this.mediaModel.textModel.behavior==MediaModel.TEXT_BEHAVIOR_AUTO){_textField.height = this.mediaModel.mediaHeight};
			_textField.background = false;
			_textField.wordWrap = this.mediaModel.textModel.behavior==MediaModel.TEXT_BEHAVIOR_AUTO ? true :false;
			_textField.border = false;
			_textField.selectable = false;
			_textField.autoSize=TextFieldAutoSize.LEFT;
			newFormat.bold = true;
			newFormat.font = this.mediaModel.textModel.font;
			newFormat.size = this.mediaModel.textModel.fontSize;
			newFormat.color = this.mediaModel.textModel.color;
			newFormat.align = this.mediaModel.textModel.align;
			
			_textField.defaultTextFormat=newFormat;
			_textField.text = this.mediaModel.textModel.content;
			
				_textField.x = (this.mediaModel.mediaWidth-_textField.width)/2;
				_textField.y =(this.mediaModel.mediaHeight-_textField.height)/2+3;
				textSprite.graphics.clear();
				textSprite.graphics.beginFill(this.mediaModel.textModel.bgColor,this.mediaModel.textModel.bgAlpha);
				textSprite.graphics.drawRect(0,0,this.mediaModel.mediaWidth,this.mediaModel.mediaHeight);
				textSprite.graphics.endFill();
			//trace("hhhhhh",_textField.maxScrollH);
			addChild(textSprite);
		}
		protected function timerCompleteHandler(event:TimerEvent=null):void
		{
			if(playMode==SuperAdvertis.PLAY_AUTO){
				_timer.stop();
				this.dispatchEvent(new AppEvent(AppEvent.MEDIA_PLAY_END,this.mediaModel,"text"));
			}
		}
		
		override public function hide():void{
			_timer.stop();
			removeAll();
			_currentStatic=MediaAbstract.CURRENT_STATIC_WAIT;
		}
	}
}