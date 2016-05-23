package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class NPC extends FlxSprite
{
	private var _isInvincible:Bool;
	private var _bubble:NPCBubble;
	
	public var name:String;
	public var distanceLook:Float = 150;
	
	public function new(?X:Float = 0, ?Y:Float = 0, npcName:String = "", text:String="", ?SimpleGraphic:FlxGraphicAsset = AssetPaths.npc__png) 
	{
		super(X, Y);
		loadGraphic(SimpleGraphic, true, 64, 64);
		animation.add("idle", [0, 1, 2, 3], 6, true);
		
		acceleration.y = Reg.gravity;
		
		name = npcName;
		
		_bubble = new NPCBubble(this, text, new FlxRect(X, Y, 200, 50)); 
		Reg.npcBubbles.add(_bubble);
		animation.play("idle", false, Reg.random.int(0, 3));
	}
	
	public function setTalking(bool:Bool, time:Float=0.2)
	{
		_bubble.show(bool, time);
	}
	
	public function lookAt(target:FlxSprite)
	{
		facing = (x - target.x > 0)?FlxObject.RIGHT:FlxObject.LEFT;
	}
	
	override public function kill():Void 
	{
		if (!_isInvincible)
			super.kill();
	}
	override public function hurt(Damage:Float):Void 
	{
		FlxFlicker.flicker(this, 0.5);
		super.hurt(Damage);
	}
}