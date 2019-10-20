package advertis.multimedia.media
{
	import advertis.multimedia.IFactory;
	import advertis.multimedia.IMedia;
	
	public class ImageFactory implements IFactory
	{
		public function ImageFactory()
		{
			
		}
		public function factory(mediaModel:Object):IMedia
		{
			return new MediaImage(mediaModel);
		}
    }
}
