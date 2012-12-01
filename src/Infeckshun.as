package
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	[SWF(width = "640", height = "480")]
	public class Infeckshun extends Engine
	{
		public function Infeckshun()
		{
			super(640, 480, 60, false);
			
			FP.world = new TitleScreen;
		}
		
	}
}
