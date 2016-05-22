package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;


class NPCBubble extends FlxTypedGroup<FlxSprite>
{
	private var _sprBack:FlxSprite;
	private var _sprBack2:FlxSprite;
	private var _title:FlxText;
	private var _text:FlxText;
	
	private var _tween:FlxTween;
	
	public var x:Float;
	public var y:Float;
	
	public function new(npc:NPC, text:String="", size:FlxRect) 
	{
		super();
		
		x = size.x - npc.width/2;
		y = size.y - size.height - 4;
		
		//No Frame
		/*_sprBack = new FlxSprite(x, y).makeGraphic(Std.int(size.width), Std.int(size.height), FlxColor.fromRGB(255,255,255,200));
		_sprBack2 = new FlxSprite(x+1, y+1).makeGraphic(Std.int(size.width - 2), Std.int(size.height - 2), FlxColor.fromRGB(0,0,0,200));
		add(_sprBack);
		add(_sprBack2);*/
		
		_title = new FlxText(x + 2, y + 2, 0, "["+npc.name+"]", 16);
		_title.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		add(_title);
		
		_text = new FlxText(x + 2, y + _title.height, size.width, text, 8);
		add(_text);
	}
	
	public function show(bool:Bool, time:Float=0.3)
	{
		if (_tween == null || _tween.finished)
		{
			if (bool)
				forEach(function(spr:FlxSprite)
				{
					_tween = FlxTween.tween(spr, { alpha: 1}, time, { ease: FlxEase.circIn });
				});
			else
				forEach(function(spr:FlxSprite)
				{
					_tween = FlxTween.tween(spr, { alpha: 0}, time*2, { ease: FlxEase.circOut });
				});
		}
	}
	
}