package
{
	import flash.display.BitmapData;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.World;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;

	public class TitleScreen extends World
	{
		public const BOTTOM_HUD_HEIGHT:int = 32;
		
		private var mainText:Text = new Text("CLEVER TITLE");
		private var subText:Text = new Text("[WRT CLONING]");
		private var directionsText:Text = new Text("press the spacebar to begin");
		private var copyrightText:Text = new Text("(C) Sam Martin, 2012");
		
		public function TitleScreen()
		{
			// TODO figure out dat CSS (?)
			FP.screen.color = 0xefe7be;
			
			mainText.color = 0x666666;
			mainText.size = 48;
			addText(mainText, FP.screen.width / 2 - mainText.width / 2, FP.screen.height / 3);
			
			subText.color = 0x888888;
			subText.size = 24;
			addText(subText, FP.screen.width / 2 - subText.width / 2, FP.screen.height / 3 + 48);
			
			directionsText.color = 0xaaaaaa;
			directionsText.size = 18;
			addText(directionsText, FP.screen.width / 2 - directionsText.width / 2, FP.screen.height / 3 + 128);
			
			copyrightText.color = 0x444444;
			copyrightText.size = 18;
			addText(copyrightText, 16, FP.screen.height - copyrightText.height - 4);
			
			initGround();
		}
		
		private function addText(text:Text, x:int, y:int):void
		{
			var textEntity:Entity = new Entity();
			textEntity.graphic = text;
			textEntity.x = x;
			textEntity.y = y;
			add(textEntity);
		}
		
		override public function update():void 
		{	
			if (Input.pressed(Key.SPACE)) {
				FP.world = new MyWorld;	
			}
			
			super.update();
		}
		
		/**
		 * Add a simple rect to the bottom of the screen.
		 */ 
		private function initGround():void
		{
			var ground:Entity = new Entity;
			ground.layer = 1;
			var groundImage:Image = new Image(new BitmapData(FP.screen.width, BOTTOM_HUD_HEIGHT));
			ground.x = 0;
			ground.y = FP.screen.height - BOTTOM_HUD_HEIGHT;
			groundImage.color = 0xbfb997;
			ground.graphic = groundImage;
			add(ground);
		}
	}
}