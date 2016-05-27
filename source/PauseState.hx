package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class PauseState extends FlxSubState
{
	private var _resumeButton:FlxButton;
	
	override public function create():Void
	{
		_resumeButton = new FlxButton(0, 0, "Resume", returnToGame);
		_resumeButton.screenCenter();
		_resumeButton.y = FlxG.height - 2 * _resumeButton.height;
		add(_resumeButton);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	public function returnToGame()
	{
		close();
	}
}