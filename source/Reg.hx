package;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxRandom;

class Reg
{

	static public var gravity:Float = 400;
	static public var random:FlxRandom;
	static public var enemies:FlxTypedGroup<Enemy>;
	static public var bullets:FlxGroup;
	static public var enemyBullets:FlxGroup;
	static public var portals:FlxTypedGroup<Portal>;
	static public var npcs:FlxTypedGroup<NPC>;
	static public var npcBubbles:FlxGroup;
	static public var player:Player;
	static public var mapPath:String;
	
	static public function init()
	{
		random = new FlxRandom();
		enemies = new FlxTypedGroup<Enemy>();
		portals = new FlxTypedGroup<Portal>();
		npcs = new FlxTypedGroup<NPC>();
		npcBubbles = new FlxGroup();
		bullets = new FlxGroup();
		enemyBullets = new FlxGroup();
	}
	
	static function getMousePos()
	{
		return FlxG.mouse.getWorldPosition();
	}
}