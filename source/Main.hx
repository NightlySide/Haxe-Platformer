package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	private var zoom:Float = 1.5;
	
	public function new()
	{
		super();
		Reg.init();
		Reg.mapPath = AssetPaths.test__tmx;
		addChild(new FlxGame(Std.int(1280/zoom), Std.int(720/zoom), PlayState));
	}
}