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

enum EnemyType
{
	BASIC;
}

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
	private var _enemyType:EnemyType;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.enemy__png, true, 64, 64);
		
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
		_enemyType = EnemyType.BASIC;
		
		drag.x = _runSpeed * 8;
		acceleration.y = Reg.gravity;
		maxVelocity.x = _runSpeed;
		maxVelocity.y = _jumpPower;
		
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		
		animation.add("run", [0, 1, 2, 3, 4, 5, 6, 7], 12);
		animation.add("idle", [6, 7, 0, 7, 6, 0], 12);
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
			lookAt(_player);
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
		
		if (velocity.y != 0)
		{
			//Don't change animation if our Y vel is zero.
		}
		else if(velocity.x == 0)
			animation.play('idle');
		else 
			animation.play('run');
	}
	
	public function lookAt(target:FlxSprite)
	{
		facing = (x - target.x > 0)?FlxObject.RIGHT:FlxObject.LEFT;
	}
	
	public function shoot()
	{
		if (_agroing && _canAttack)
		{
			var bullet:Bullet = new Bullet(AssetPaths.enemy_bullet__png);
			var angle:Float = FlxAngle.angleBetween(this, _player);
			bullet.speed = Reg.random.int(150, 250);
			bullet.damage = 5;
			bullet.shoot(new FlxPoint(x+32, y+40), angle);
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
	
	override public function kill():Void 
	{
		Reg.enemiesKilled.set(_enemyType, Reg.enemiesKilled.get(_enemyType) + 1);
		super.kill();
	}
	
	static public function getEnemyTypeByString(str:String)
	{
		switch(str.toLowerCase())
		{
			case "basic":
				return EnemyType.BASIC;
		}
		return null;
	}
}