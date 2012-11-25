package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import net.flashpunk.World;
	import net.flashpunk.graphics.Image;
	
	public class HumanOutline
	{
		// the outline should be behind pretty much everything else
		private static const LAYER:int = 9999;
		
		[Embed(source='assets/human_outline.png')] private const OUTLINE:Class;
		
		private var percentComplete:uint = 0;
		private var outline:Entity = new Entity;
		private var progressBar:Entity = new Entity;
		private var world:World;
		
		public function HumanOutline(world:World, x:uint, y:uint)
		{
			outline.graphic = new Image(OUTLINE);			
			outline.layer = LAYER;
			outline.x = x;
			outline.y = y;
			
			progressBar.graphic = new Image(new BitmapData(65, 1, false, 0xb2e335));						
			progressBar.layer = LAYER + 1; // behind the outline graphic
			progressBar.x = x;
			progressBar.y = y + 116;
			
			world.add(outline);
			world.add(progressBar);
		}
		
		public function set progress(percent:uint):void
		{
			percentComplete = percent;
			
			var h:uint = Math.max(112 * (percentComplete / 100), 1);
			progressBar.graphic = new Image(new BitmapData(65, h, false, 0xb2e335));
			progressBar.y = outline.y + 116 - h;
		}
	}
}