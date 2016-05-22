package;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import Player;

class HUD extends FlxTypedGroup<FlxSprite>
{
	private var _player:Player;
	private var _txtHealth:FlxText;
	private var _sprHealth:FlxSprite;
	
	public function new(player:Player) 
	{
		super();
		_player = player;
		
		_txtHealth = new FlxText(40, 4, 0, Std.string(_player.health) + " / " + Std.string(_player.maxHealth), 16);
        _txtHealth.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		add(_txtHealth);
		_sprHealth = new FlxSprite(8, _txtHealth.y + _txtHealth.height/8 - 6, AssetPaths.heart__png);
		_sprHealth.scale.set(1.5, 1.5);
		add(_sprHealth);
		
		forEach(function(spr:FlxSprite)
		{
			spr.scrollFactor.set(0, 0);
		});
	}
	
	public function updateHUD()
	{
		_txtHealth.text = Std.string(_player.health) + " / " + Std.string(_player.maxHealth);
	}
	
}