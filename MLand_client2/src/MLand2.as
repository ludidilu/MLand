package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import application.InitApplication;
	
	import debug.CatchError;
	
	[SWF(width="960",height="640",frameRate="60")]
	public class MLand2 extends Sprite
	{
		public function MLand2()
		{
			addEventListener(Event.ADDED_TO_STAGE,addedToStage);
		}
		
		private function addedToStage(e:Event):void{
			
			removeEventListener(Event.ADDED_TO_STAGE,addedToStage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			
			CatchError.init(this);
			
			InitApplication.start(stage);
		}
		
	}
}