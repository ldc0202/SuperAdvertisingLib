package events
{
	import flash.events.Event;
	
	public class AppEvent extends Event
	{
		//eventTypes///////////////////////////////////
		public static const EVENT_REGIST_PAGE_BY_ID:String  = "event_regist_page_by_id";
		public static const EVENT_ON_BUTTON_CLICK:String	= "event_on_button_click";
		public static const EVENT_ON_SHOP_CLICK:String 		= "event_on_shop_click";
		public static const EVENT_REGIST_BUTTON:String		= "event_regist_button";
		public static const EVENT_NAVIGATE_TO_URL:String    = "event_navigate_to_url";
		public static const EVENT_CHANGE_FLOOR:String 		= "event_change_floor";
		public static const EVENT_SHOW_IMGS:String 			= "event_show_imgs";
		public static const EVENT_CHANGE_HTMLY:String 		= "event_change_html";
		public static const NEWSITME_CLICK:String           ="event_TitleName";
		public static const CHANGE_HTMLY:String				= "change_htmly";
		public static const MEDIA_PLAY_END:String 			= "media_play_end" ;
		public static const STAGEVIDEO_PLAYING:String 		= "stagevideo_playing" ;
		public static const SHOW_WINDOWS_LAYOUT:String 		= "show_windows_layout" ;
		public static const LAYOUT_PLAY_END:String 		    = "layout_play_end" ;
		///////////////////////////////////////////////
		
		public var data:Object;
		public var info:String;
		
		public function AppEvent(type:String, $data:Object = null, $info:String = "", bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = $data;
			this.info = $info;
		}
	}
}