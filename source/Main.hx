package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	private var zoom:Int = 3;
	
	public function new()
	{
		super();
		addChild(new FlxGame(Std.int(1280/zoom), Std.int(720/zoom), PlayState));
	}
}