package advertis.multimedia.media
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class Loading extends Sprite
	{
		[Embed(source="skin/loadingSkin.swf")]
		private static const EmbedDiffuse:Class;
		private var _loader:Loader;
		private var _W:Number;
		private var _H:Number;
		public function Loading(containerW:Number,containerH:Number)
		{
			super();
			_W=containerW;
			_H=containerH
			addLoadingSkin();
		}
		private function addLoadingSkin():void{
			var loading:MovieClip = new EmbedDiffuse() as MovieClip ;
			addChild(loading);
			loading.x=(_W-loading.width)/2;
			loading.y=(_H-loading.height)/2;
		}
		public function close():void{
			this.visible=false;
		}
	}
}