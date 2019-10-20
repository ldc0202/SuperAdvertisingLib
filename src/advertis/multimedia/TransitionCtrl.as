package advertis.multimedia
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import advertis.SuperAdvertis;
	import advertis.multimedia.media.MediaStageVideo;
	
	import fl.transitions.Blinds;
	import fl.transitions.Fade;
	import fl.transitions.Photo;
	import fl.transitions.PixelDissolve;
	import fl.transitions.Squeeze;
	import fl.transitions.Transition;
	import fl.transitions.TransitionManager;

	public class TransitionCtrl
	{
		private var _container:Sprite;
		private var _containerWidth:Number;
		private var _containerHeight:Number;
		public var transitionEndCallBack:Function;
		public function TransitionCtrl(container:Sprite,containerWidth:Number,containerHeight:Number)
		{
			_container=container;
			_containerWidth=containerWidth;
			_containerHeight=containerHeight;
			transitionArr=[{label:"遮帘过渡",type:Blinds},{label:"淡化过渡",type:Fade},{label:"照片过渡",type:Photo},{label:"像素溶解过渡",type:PixelDissolve},{label:"挤压过渡",type:Squeeze}];
		}
		/**
		 * @param transtionNum 切换效果动画：0，遮帘过渡 1，淡化过渡，2，照片过渡。3，像素溶解过渡。4。挤压过渡，5，向左滚动。6，向右滚动，7，左右随机。8,当前媒体淡出完后，下一个媒体再淡入9
		 */
		public function transitionIn(transitionID:int=5):void{
			if(_container.numChildren!=2 ){
				end();
			}
			if(_container.numChildren==2){
				var m1:DisplayObject=_container.getChildAt(0);
				var m2:DisplayObject=_container.getChildAt(1);
				//两个相同的媒体不做切换防止渐变闪一下。
				if(MediaAbstract(m1) && MediaAbstract(m2) && MediaAbstract(m1).mediaModel.ID==MediaAbstract(m2).mediaModel.ID && MediaAbstract(m2).mediaModel.type!=MediaModel.TEXT){
					end();
					return;
				}
				m1.x=m2.x=m1.y=m2.y=0;
				switch(transitionID)
				{
					case 0:
					{
						transition(m1,m2,transitionID);
						break;
					}
					case 1:
					{
						transition(m1,m2,transitionID);
						break;
					}
					case 2:
					{
						transition(m1,m2,transitionID);
						break;
					}
					case 3:
					{
						transition(m1,m2,transitionID);
						break;
					}
					case 4:
					{
						transition(m1,m2,transitionID);
						break;
					}
					case 5:
					{
						soliAction(transitionID);
						break;
					}
					case 6:
					{
						soliAction(transitionID);
						break;
					}
					case 7:
					{
						soliAction(transitionID);
						break;
					}
					case 8:
					{
						soliAction(transitionID);
						break;
					}
					case 9:
					{
						alphaOutAndIn(m1,m2);
						break;
					}
					default:
					{
						break;
					}
				}
				
				
			}
		}
		private function onTransDone(e:Event):void
		{
			trace("trans is done")
			end();
		}
		private var t1:TweenLite,t2 :TweenLite;
		private var trans1:TransitionManager;
		private var trans2:TransitionManager;
		
		private var transitionArr:Array;
		
		/**
		 * 当前媒体淡出完后，下一个媒体再淡入；
		 * */
		private function alphaOutAndIn(m_1:DisplayObject,m_2:DisplayObject):void{
			m_2.alpha=0;
			var tween:TweenLite=TweenLite.to(m_1,1,{alpha:0,onComplete:m1CompleteHandler});
			function m1CompleteHandler():void{
				m_2.visible=true;
				var tween:TweenLite=TweenLite.to(m_2,0.5,{alpha:1,onComplete:comp});
			}
			function comp():void{
				m_1.visible=false;
				end();
			}
		}
		/**
		 * 转场
		 * */
		private function transition(m_1:DisplayObject,m_2:DisplayObject,transitionID:int=5):void{
			var transParam:Object=new Object()
			var obj:Object=transitionArr[transitionID]
			transParam.type=obj.type;
			transParam.direction=Transition.IN
			transParam.duration=1;
			//transParam.easing=Elastic.easeIn;
			//transParam.easing=Elastic.easeInOut
			//第1种使用方法，能注册事件
			
			if(!trans1){trans1=new TransitionManager(MovieClip(m_2))};
			trans1.content=MovieClip(m_2);
			trans1.startTransition(transParam)
			trans1.addEventListener("allTransitionsInDone",onTransDone)
			//transParam.direction=Transition.OUT;
			//第1种使用方法，能注册事件
			if(!trans2){trans2=new TransitionManager(MovieClip(m_1))};
			trans2.content=MovieClip(m_2);
			trans2.startTransition(transParam)
			
			//第2种方法，不能注册事件
			//TransitionManager.start(mc,transParam)
		}
		/**
		 * xy控制滚动
		 * */
		private function soliAction(n:int):void{
			var leftRight:Number=0;
			if(_container.numChildren>2){
				end();
			}
			if(n==5){
				leftRight=1
			}else if(n==6){
				leftRight=-1
			}else{
				leftRight=Math.floor(6*Math.random());
				leftRight>3? leftRight=1 : leftRight=-1;
			}
			if(_container.numChildren==2){
				var m1:DisplayObject=_container.getChildAt(0);
				var m2:DisplayObject=_container.getChildAt(1);
				m2.x=_containerWidth*leftRight;
				TweenLite.killTweensOf(m1,true);
				TweenLite.killTweensOf(m2,true);
				m2.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
				//t1 = TweenLite.to(m1,2,{scaleX:1, scaleY:1 ,alpha:1, x:-_containerWidth*leftRight,y:0, onComplete:end } );
				//t2 = TweenLite.to(m2,2,{scaleX:1, scaleY:1 ,alpha:1,x:0 ,y:0,onComplete:end} );
				
				function enterFrameHandler(e:Event):void{
					var temp:Number=-_containerWidth*leftRight;
					m1.x=m1.x+(temp-m1.x)/5;
					m2.x=m2.x+(0-m2.x)/5;
					if(m1.x-temp<1 && m1.x-temp>-1 && m2.x<1 && m2.x>-1){
						m2.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
						end();
					}
				}
			}
		}
		
		public function end():void
		{
			if(t1 && t2){
				t1.kill();
				t2.kill();
				MediaAbstract(t1.target).x=-_containerWidth;
				MediaAbstract(t2.target).x=0;
			}
			if(_container.numChildren>1)
			{
				var m1:IMedia=IMedia(_container.getChildAt(0));
				m1.hide();
				_container.removeChildAt(0);
			}
			if(transitionEndCallBack!=null){transitionEndCallBack();};
		}
	}
}