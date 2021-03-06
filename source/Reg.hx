package;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxRandom;
import Enemy;
import NPC;

enum ItemTypes {
	GOLD;
	FLOWER;
}

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
	
	//Objectives variables
	static public var enemiesKilled:Map<EnemyType, Int>;
	static public var itemPickuped:Map<ItemTypes, Int>;
	static public var npcTalkedTo:Map<NPC, Bool>;
	
	static public function init()
	{
		random = new FlxRandom();
		enemies = new FlxTypedGroup<Enemy>();
		portals = new FlxTypedGroup<Portal>();
		npcs = new FlxTypedGroup<NPC>();
		npcBubbles = new FlxGroup();
		bullets = new FlxGroup();
		enemyBullets = new FlxGroup();
		
		//Objective variables
		npcTalkedTo = new Map<NPC, Bool>();
		enemiesKilled = new Map<EnemyType, Int>();
		itemPickuped = new Map<ItemTypes, Int>();
		for (type in Type.allEnums(EnemyType))
			enemiesKilled.set(type, 0);
		for (type in Type.allEnums(ItemTypes))
			itemPickuped.set(type, 0);
		
	}
	
	static public function reset()
	{
		enemies = new FlxTypedGroup<Enemy>();
		portals = new FlxTypedGroup<Portal>();
		npcs = new FlxTypedGroup<NPC>();
		npcBubbles = new FlxGroup();
		bullets = new FlxGroup();
		enemyBullets = new FlxGroup();
	}
	
	static function getMousePos()
	{
		#if desktop
		return FlxG.mouse.getWorldPosition();
		#end
		return null;
	}
}