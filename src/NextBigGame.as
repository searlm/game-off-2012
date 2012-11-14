package
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	[SWF(width = "640", height = "480")]
	public class NextBigGame extends Engine
	{
		public function NextBigGame()
		{
			super(640, 480, 30, false);
			
			FP.world = new TitleScreen;
		}
		
	}
}
