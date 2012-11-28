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
		
		[Embed(source='assets/hero_400x439.png')] 
		private const HERO:Class;
		
		[Embed(source = 'assets/Blackout Midnight.ttf', embedAsCFF="false", fontFamily = 'Blackout Midnight')] 
		private const MAIN_FONT:Class;
		
		private var mainText:Text = new Text("infeckshun");		
		private var directionsText:Text = new Text("press the spacebar to begin");
		private var copyrightText:Text = new Text("(C) Sam Martin, 2012");
		
		public function TitleScreen()
		{
			// TODO figure out dat CSS (?)			
			FP.screen.color = 0x2b2b2b;
			
			var hero:Entity = new Entity;
			hero.x = FP.screen.width - 400;
			hero.y = 0;
			
			var heroImage:Image = new Image(HERO);
			heroImage.alpha = 0.3;
			hero.graphic = heroImage;
			
			add(hero);
			
			mainText.color = 0xf9f9f9;
			mainText.size = 56;
			mainText.font = "Blackout Midnight";
			addText(mainText, 32, FP.screen.height / 2);
			
			directionsText.color = 0xdddddd;
			directionsText.size = 20;
			directionsText.font = "Blackout Midnight";
			addText(directionsText, 32, FP.screen.height / 2 + 64);
			
			copyrightText.color = 0x999999;
			copyrightText.size = 18;
			copyrightText.font = "Blackout Midnight";
			addText(copyrightText, FP.screen.width - copyrightText.width - 4, FP.screen.height - copyrightText.height - 4);			
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
	}
}