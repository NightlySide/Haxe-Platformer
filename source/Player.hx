package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	private var _maxHealth:Float  = 100;
	private var _runSpeed:Float   = 150;
	private var _jumpPower:Float  = 200;
	private var _spawnPoint:FlxPoint;
	
	public function new(?X:Float=0, ?Y:Float=0, W:Int=16, H:Int=32) 
	{	
		_spawnPoint = new FlxPoint(X, Std.int(Y - H/2));
		health = _maxHealth;
		
		super(_spawnPoint.x, _spawnPoint.y);
		
		makeGraphic(W, H, FlxColor.BLUE);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		/*
		width = W;
		height = H;
		offset.set(27, 24);
		scale.set(1/2, 1/2);
		*/
		
		drag.x = _runSpeed * 8;
		acceleration.y = Reg.gravity;
		maxVelocity.x = _runSpeed;
		maxVelocity.y = 3 * _jumpPower;
		
		/*animation.add("idle", [2]);
		animation.add("run", [3, 4, 5, 6, 7, 8, 9, 10], 12);
		animation.add("jump", [11, 12, 13, 14], 10, false);*/
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
			
		if (velocity.x != 0) 
			facing = (velocity.x > 0) ? FlxObject.RIGHT : FlxObject.LEFT;
			
		if (velocity.y == 0 && up && isTouching(FlxObject.DOWN)) 
		{
			velocity.y = -_jumpPower;
			//animation.play('jump');
		}
		
		/*if (velocity.y != 0)
		{
			//Don't change animation if our Y vel is zero.
		}
		else if(velocity.x == 0)
			animation.play('idle');
		else 
			animation.play('run');*/
	}
	
	override public function update(elapsed:Float):Void 
	{
		movement();
		super.update(elapsed);
	}
}