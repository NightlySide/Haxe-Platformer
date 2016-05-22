package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class Enemy extends FlxSprite
{
	private var _target:FlxSprite;
	private var _targetDirection:Int;
	private var _healthMax:Float;
	private var _reloadTime:Float;
	private var _shootTimer:Float;
	private var _jumpPower:Float;
	private var _runSpeed:Float;
	private var _player:Player;
	private var _canWalk:Bool;
	private var _canJump:Bool;
	private var _agroDist:Float;
	private var _agroing:Bool;
	private var _canAttack:Bool;
	private var _reloadJump:Int;
	private var _jumpTimer:Int;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		makeGraphic(32, 32, FlxColor.RED);
		
		_canJump = true;
		_canWalk = true;
		_agroDist = 400;
		_runSpeed = Reg.random.int(50, 70);
		_jumpPower = 200;
		_agroing = false;
		_canAttack = false;
		_reloadJump = 100;
		_reloadTime = 100;
		_healthMax = 50;
		
		drag.x = _runSpeed * 8;
		acceleration.y = Reg.gravity;
		maxVelocity.x = _runSpeed;
		maxVelocity.y = _jumpPower;
		
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
	}
	
	public function init(xPos:Float, yPos:Float, player:Player) 
	{
		reset(xPos + offset.x, yPos + offset.y);
		_player = player;
		
		_target = _player;
		health = _healthMax;
		_shootTimer = 0;
		_jumpTimer = _reloadJump;
		
		if(animation.getByName("idle") != null)
			animation.play('idle');
	}
	
	public function updateDetection()
	{
		var distanceToPlayer = getMidpoint().distanceTo(_player.getMidpoint());
		if (distanceToPlayer <= _agroDist)
		{
			_agroing = true;
			_canAttack = true;
		}
		else
		{
			_agroing = false;
			_canAttack = false;
		}
	}
	
	public function movement()
	{
		acceleration.x = 0;
		var isTargetRight:Bool = Math.abs(FlxAngle.angleBetween(this, _target)) < (Math.PI * 0.5);
		_targetDirection = (isTargetRight) ? FlxObject.RIGHT : FlxObject.LEFT;
		
		if (_agroing)
		{
			if (_canWalk && velocity.y <= 0)
			{
				if(animation.getByName("run") != null)
					animation.play('run');
				acceleration.x += (_targetDirection == FlxObject.RIGHT) ? drag.x : -drag.x;
				
				if ((isTouching(FlxObject.RIGHT) || isTouching(FlxObject.LEFT)) && isTouching(FlxObject.DOWN) && _jumpTimer < 0)
				{
					velocity.y = -_jumpPower;
					_jumpTimer = _reloadJump;
				}
			}
		}
	}
	
	public function shoot()
	{
		if (_agroing && _canAttack)
		{
			var bullet:Bullet = new Bullet();
			var angle:Float = FlxAngle.angleBetween(this, _player);
			bullet.speed = Reg.random.int(150, 250);
			bullet.damage = 5;
			bullet.shoot(new FlxPoint(x, y), angle);
			Reg.enemyBullets.add(bullet);
			
			_shootTimer = _reloadTime;
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_jumpTimer -= 1;
		_shootTimer -= 1;
		_canAttack = (_shootTimer <= 0);
		
		shoot();
	}
	
	override public function hurt(Damage:Float):Void 
	{
		super.hurt(Damage);
		FlxFlicker.flicker(this, 0.5);
	}
	
}