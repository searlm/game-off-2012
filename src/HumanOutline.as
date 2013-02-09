package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.World;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	
	/**
	 * Helper class for drawing the overall progress bar.
	 */
	public class HumanOutline
	{
		// the outline should be behind pretty much everything else
		private static const LAYER:int = 9999;
		
		[Embed(source='assets/human_outline.png')]
        private const OUTLINE:Class;

		private var outline:Entity = new Entity;
		private var progressBar:Entity = new Entity;
		private var percentText:Text = new Text("0%");
		private var percentTextEntity:Entity;
		
		public function HumanOutline(world:World, x:uint, y:uint)
		{
			outline.graphic = new Image(OUTLINE);			
			outline.layer = LAYER;
			outline.x = x;
			outline.y = y;

			progressBar.graphic = new Image(new BitmapData(65, 1, false, 0xb2e335));						
			progressBar.layer = LAYER;
			progressBar.x = x;
			progressBar.y = y + 116;
						
			percentText.font = "MainFont"; // embedded in MyWorld.as
			percentText.color = 0xfafafa;
			percentText.size = 28;
			
		    percentTextEntity = new Entity;			
			percentTextEntity.graphic = percentText;
			percentTextEntity.layer = LAYER;
			percentTextEntity.x = outline.x + 2 + 65 / 2 - percentText.width / 2;
			percentTextEntity.y = outline.y + 60 - percentText.height / 2;
			
			world.add(progressBar);
			world.add(outline);
			world.add(percentTextEntity);
		}
		
		/**
		 * Update the completion percentage.
		 */
		public function set progress(percent:uint):void
		{
			percentText.text = percent + "%";
			percentTextEntity.x = outline.x + 2 + 65 / 2 - percentText.width / 2;
			percentTextEntity.y = outline.y + 60 - percentText.height / 2;
			
			var h:uint = Math.max(112 * (percent / 100), 1);
			progressBar.graphic = new Image(new BitmapData(65, h, false, 0xb2e335));
			progressBar.y = outline.y + 116 - h;
		}
		
		/**
		 * Bring the graphics forward above the overlay layer (used in the death sequence).
		 */
		public function toForeground():void
		{
			progressBar.layer = 0;
			percentTextEntity.layer = 0;
			outline.layer = 0;
		}
	}
}