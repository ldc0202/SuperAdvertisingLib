package advertis.multimedia.media
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import advertis.SuperAdvertis;
	import advertis.multimedia.IMedia;
	import advertis.multimedia.MediaAbstract;
	import advertis.multimedia.MediaModel;
	
	import events.AppEvent;
	
	public class MediaSubTitleText extends MediaAbstract implements IMedia
	{
		private var _moutimediaWidth:Number;//弹幕的宽度;
		private var _moutimediaHeight:Number;//弹幕的高度
		private var _timer:Timer;
		/**
		 * 这个时间变成了在多长时间后发出另外一个弹幕,数据只在滚出左边界时自动清除
		 * */
		private var _residenceTime:Number;
		private var _loading:Loading;
		private var _frequency:uint;
		private var _isSubtitle:Boolean=false;
		private var _thisContainer:MediaSubTitleText
		public function MediaSubTitleText(mediaModel:Object)
		{
			super();
			_currentStatic=MediaAbstract.CURRENT_STATIC_READY;
			addMedia(MediaModel(mediaModel));
		}
		/**
		 * 弹幕文字；对其它布局播放的字幕不在这里实现
		 * */
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
			//if(_textField){return};
			_moutimediaWidth=this.mediaModel.mediaWidth;
			_moutimediaHeight=this.mediaModel.mediaHeight;
			_frequency=this.mediaModel.frequency;
			_residenceTime=this.mediaModel.residenceTime;
			_timer=new Timer(_residenceTime,_frequency);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,timerCompleteHandler);
			
			var textSprite:Sprite=new Sprite();
				//mediaModel.mediaHeight=mediaModel.text_fontSize;
				this.mediaModel.textModel.bgAlpha=0;
				textSprite.filters=[new DropShadowFilter(0)];
				
			_textField = new TextField();
			textSprite.addChild(_textField);
			_textField.type=TextFieldType.DYNAMIC;
			_textField.background = false;
			_textField.wordWrap = false;
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
			//trace("hhhhhh",_textField.maxScrollH);
			_thisContainer=this;
			_thisContainer.addChild(textSprite);
			subtitleAction(textSprite);
		}
		/**
		 * 弹屏字幕滚动
		 * */
		private var textSpriteArr:Array=[];
		private var _speek:Number=10;
		private function subtitleAction(disp:DisplayObject):void{
			textSpriteArr.push(disp);
			disp.x=_moutimediaWidth//_moutimediaWidth+Math.random()*_moutimediaWidth;
			disp.y=0//(_moutimediaHeight-disp.height)*Math.random();
			this.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			for each (var i:DisplayObject in textSpriteArr) 
			{
				i.x-=_speek;
				if(i.x<-i.width){
					textSpriteArr.splice(textSpriteArr.indexOf(i),1);
					try
					{
						var textSpriteIndex:int=_thisContainer.getChildIndex(i);
						_thisContainer.removeChild(i);
						if(playMode==SuperAdvertis.PLAY_AUTO){
							_timer.stop();
							this.dispatchEvent(new AppEvent(AppEvent.MEDIA_PLAY_END,this.mediaModel,"text"));
						}
					} 
					catch(error:Error) 
					{
						textSpriteArr=[];
					}
				}
			}
			if(textSpriteArr.length==0){
				this.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
			}
		}
		protected function timerCompleteHandler(event:TimerEvent=null):void
		{
			//待定是否滚动完再切换
			    // _timer.stop();
				//this.dispatchEvent(new AppEvent(AppEvent.MEDIA_PLAY_END,this.mediaModel,"text"));
		}
		
		override public function hide():void{
			_timer.stop();
			this.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
			for(var i:int=0;i<this.numChildren;i++){
				this.removeChildAt(0);
			}
			_currentStatic=MediaAbstract.CURRENT_STATIC_WAIT;
		}
	}
}