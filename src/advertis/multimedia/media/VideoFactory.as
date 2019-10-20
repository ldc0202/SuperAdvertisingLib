package advertis.multimedia.media
{
	import advertis.multimedia.IFactory;
	import advertis.multimedia.IMedia;
	
	public class VideoFactory implements IFactory
	{
		public function VideoFactory()
		{
		}
		
		public function factory(mediaModel:Object):IMedia
		{
			return new MediaVideo(mediaModel);
			//return new MediaStageVideo(mediaModel);
		}
	}
}