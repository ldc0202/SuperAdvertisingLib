package advertis.multimedia.media
{
	import advertis.multimedia.IFactory;
	import advertis.multimedia.IMedia;
	
	public class SwfFactory implements IFactory
	{
		public function SwfFactory()
		{
			
		}
		public function factory(mediaModel:Object):IMedia
		{
			return new MediaSwf(mediaModel);
		}
	}
}