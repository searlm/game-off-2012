package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Sfx;
	import net.flashpunk.World;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	
	public class HumanOutline
	{
		// the outline should be behind pretty much everything else
		private static const LAYER:int = 9999;
		
		[Embed(source='assets/human_outline.png')] private const OUTLINE:Class;
		
		private var percentComplete:uint = 0;
		private var outline:Entity = new Entity;
		private var progressBar:Entity = new Entity;
		private var world:World;
		private var percentText:Text = new Text("0%");
		private var percentTextEntity:Entity;
		
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
			
			percentText.color = 0xfafafa;
			percentText.size = 15;
			
		    percentTextEntity = new Entity;			
			percentTextEntity.graphic = percentText;
			percentTextEntity.x = outline.x + 2 + 65 / 2 - percentText.width / 2;
			percentTextEntity.y = outline.y + 60 - percentText.height / 2;
			
			world.add(outline);
			world.add(progressBar);
			world.add(percentTextEntity);
		}
		
		public function set progress(percent:uint):void
		{
			percentComplete = percent;
			
			percentText.text = percent + "%";
			percentTextEntity.x = outline.x + 2 + 65 / 2 - percentText.width / 2;
			percentTextEntity.y = outline.y + 60 - percentText.height / 2;
			
			var h:uint = Math.max(112 * (percentComplete / 100), 1);
			progressBar.graphic = new Image(new BitmapData(65, h, false, 0xb2e335));
			progressBar.y = outline.y + 116 - h;
		}
	}
}