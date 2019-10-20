package advertis.multimedia.media
{
	import advertis.multimedia.IFactory;
	import advertis.multimedia.IMedia;
	
	public class TextFactory implements IFactory
	{
		public function TextFactory()
		{
			
		}
		public function factory(mediaModel:Object):IMedia
		{
			return new MediaText(mediaModel);
		}
		public function factorySubTitle(mediaModel:Object):IMedia
		{
			return new  MediaSubTitleText(mediaModel);
		}
    }
}
