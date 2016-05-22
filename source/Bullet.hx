package;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class Bullet extends FlxSprite
{
	public var speed:Float;
	public var damage:Float;
	
	private var dieOnHitWall:Bool;
	private var dieOnHitEnemy:Bool;
	
	public function new(graphicAsset:FlxGraphicAsset=AssetPaths.bullet__png, W:Int=16, H:Int=16) 
	{
		super();
		
		loadGraphic(graphicAsset, false, W, H);
			
		scale.set(0.5, 0.5);
		height = 8;
		width = 12;
		dieOnHitWall = true;
		dieOnHitEnemy = true;
		
		damage = 10;
	}
	
	override public function update(elapsed:Float):Void
	{
		if (!alive) 
		{
			if (animation.finished) 
			{
				exists = false;
			}
		}
		else if (dieOnHitWall && touching != 0) 
		{
			kill();
		}
		
		super.update(elapsed);
	}
	
	override public function kill():Void
	{
		if(!alive)
		{
			return;
		}
		
		acceleration.x = 0;
		acceleration.y = 0;
		velocity.x = 0;
		velocity.y = 0;
		angularVelocity = 0;
		
		alive = false;
		solid = false;
	}
	
	public function shoot(startLocation:FlxPoint, rotationAngle:Float):Void
	{
		reset(startLocation.x - width / 2, startLocation.y - height / 2);
		solid = true;
		angle = FlxAngle.asDegrees(rotationAngle);
		velocity.x = Math.cos(rotationAngle) * speed;
		velocity.y = Math.sin(rotationAngle) * speed;
	}
	
}