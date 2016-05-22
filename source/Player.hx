package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	public var maxHealth:Float;
	private var _runSpeed:Float   = 250;
	private var _jumpPower:Float  = 300;
	private var _spawnPoint:FlxPoint;
	private var _weaponOffset:FlxPoint;
	
	public function new(?X:Float=0, ?Y:Float=0, W:Int=64, H:Int=64) 
	{	
		_spawnPoint = new FlxPoint(X, Std.int(Y - H / 2));
		maxHealth = 100;
		
		super(_spawnPoint.x, _spawnPoint.y);
		
		loadGraphic(AssetPaths.player__png, true, 64, 64);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		width = 32;
		height = 64;
		offset.set(16, 0);
		_weaponOffset = new FlxPoint(40+offset.x, 30);
		
		drag.x = _runSpeed * 8;
		acceleration.y = Reg.gravity;
		maxVelocity.x = _runSpeed;
		maxVelocity.y = 3 * _jumpPower;
		
		animation.add("idle", [0]);
		animation.add("run", [1, 2, 3, 4, 5, 6, 7, 8], 18);
		animation.add("jump", [9, 10, 11, 12], 10, false);
		
		health = maxHealth;
	}
	
	private function movement()
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;
		 
		up = FlxG.keys.anyPressed([UP, Z, SPACE]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, Q]);
		right = FlxG.keys.anyPressed([RIGHT, D]);
		
		acceleration.x = 0;
		if (left)
			acceleration.x -= drag.x;
		else if (right)
			acceleration.x += drag.x;
			
		facing = (FlxG.mouse.x > x) ? FlxObject.RIGHT : FlxObject.LEFT;
		_weaponOffset.x = (facing == FlxObject.RIGHT) ? 40-16 : 20-16;
			
		if (velocity.y == 0 && up && isTouching(FlxObject.DOWN)) 
		{
			velocity.y = -_jumpPower;
			animation.play('jump');
		}
		
		if (velocity.y != 0)
		{
			//Don't change animation if our Y vel is zero.
		}
		else if(velocity.x == 0)
			animation.play('idle');
		else 
			animation.play('run');
	}
	
	public function shoot()
	{
		var click:Bool = FlxG.mouse.justPressed;
		if (click)
		{
			var pos:FlxSprite = new FlxSprite(getMidpoint().x, getMidpoint().y);
			var angle:Float = FlxAngle.angleBetweenMouse(pos);
			
			var bullet:Bullet = new Bullet();
			bullet.speed = 400;
			bullet.shoot(new FlxPoint(x+_weaponOffset.x, y+_weaponOffset.y), angle);
			Reg.bullets.add(bullet);
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		movement();
		shoot();
		super.update(elapsed);
	}
}