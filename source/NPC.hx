package;

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
	
	public function new(?X:Float = 0, ?Y:Float = 0, npcName:String = "", text:String="", ?SimpleGraphic:FlxGraphicAsset = AssetPaths.npc__png) 
	{
		super(X, Y);
		loadGraphic(SimpleGraphic, true, 64, 64);
		acceleration.y = Reg.gravity;
		
		name = npcName;
		
		_bubble = new NPCBubble(this, text, new FlxRect(X, Y, 200, 50)); 
		Reg.npcBubbles.add(_bubble);
	}
	
	public function setTalking(bool:Bool, time:Float=0.3)
	{
		_bubble.show(bool, time);
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