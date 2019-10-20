package advertis.multimedia
{
	public class TextModel
	{
		public var layoutWidth:Number;
		public var layoutHeight:Number;
		public var layoutX:Number;
		public var layoutY:Number;
		public var type:String;
		
		public var font:String="微软雅黑";
		public var fontSize:int=18;
		public var color:uint=0xfffff;
		public var align:String="left";
		public var behavior:String="single";
		public var bgColor:uint=0x00000;
		public var bgAlpha:Number=1;
		public var content:String="文字内容";
		public function TextModel(obj:Object=null,layoutObj:Object=null)
		{
			if(!obj){return};
			font    = layoutObj.Font;
			fontSize= int(layoutObj.FontSize);
			color= uint(layoutObj.Color);
			align= layoutObj.Align;
			behavior=layoutObj.Behavior;
			bgColor=uint(layoutObj.BgColor);
			bgAlpha=Number(layoutObj.BgAlpha);
			content=obj.Content;
		}
	}
}