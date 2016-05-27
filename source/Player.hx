package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;
import Quest;

class Player extends FlxSprite
{
	public var maxHealth:Float;
	public var money:Int = 0;
	public var exp:Float = 0;
	public var quests:Array<Quest>;
	public var activeQuestID:Int;
	
	private var _runSpeed:Float   = 250;
	private var _jumpPower:Float  = 300;
	private var _spawnPoint:FlxPoint;
	private var _weaponOffset:FlxPoint;
	private var _fireCoolDown:Float;
	
	#if mobile
	public var virtualPad:FlxVirtualPad;
	#end
	
	public function new(?X:Float=0, ?Y:Float=0, W:Int=64, H:Int=64) 
	{	
		_spawnPoint = new FlxPoint(X, Std.int(Y - H / 2));
		maxHealth = 100;
		quests = new Array<Quest>();
		quests.push(new Quest("tutorial"));
		activeQuestID = quests[0].id;
		
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
		_fireCoolDown = 0;
		#if mobile
		var h:Float;
		virtualPad = new FlxVirtualPad(FlxDPadMode.LEFT_RIGHT, FlxActionMode.A_B);
		virtualPad.alpha = 0.7;
		h = virtualPad.buttonLeft.height;
		virtualPad.scale.set(2, 2);
		virtualPad.buttonLeft.x = 32;
		virtualPad.buttonRight.x = virtualPad.buttonLeft.x + 96;
		virtualPad.buttonB.x = FlxG.width - 32 - virtualPad.buttonB.width;
		virtualPad.buttonA.x = virtualPad.buttonB.x - 48 - virtualPad.buttonA.width;
		
		virtualPad.forEach(function (spr:FlxSprite)
		{
			spr.y = FlxG.height - h - 32;
			spr.setSize(64, 64);
		});
		#end
	}
	
	private function movement()
	{ 
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;
		
		#if !FLX_NO_KEYBOARD
		up = FlxG.keys.anyPressed([UP, Z, SPACE]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, Q]);
		right = FlxG.keys.anyPressed([RIGHT, D]);
		#end
		
		#if mobile
		up = up || virtualPad.buttonA.pressed;
		down = down || virtualPad.buttonB.pressed;
		left  = left || virtualPad.buttonLeft.pressed;
		right = right || virtualPad.buttonRight.pressed;
		#end
		
		acceleration.x = 0;
		if (left)
			acceleration.x -= drag.x;
		else if (right)
			acceleration.x += drag.x;
		
		#if desktop
		facing = (FlxG.mouse.x > x) ? FlxObject.RIGHT : FlxObject.LEFT;
		#end
		#if mobile
		if (velocity.x != 0)
			facing = (velocity.x < 0)?FlxObject.LEFT:FlxObject.RIGHT;
		#end
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
		#if desktop
		var click:Bool = FlxG.mouse.justPressed;
		#end
		#if mobile
		var click:Bool = virtualPad.buttonB.pressed;
		#end
		if (click && _fireCoolDown < 0)
		{
			var pos:FlxSprite = new FlxSprite(getMidpoint().x, getMidpoint().y);
			var angle:Float = (facing == FlxObject.LEFT) ? Math.PI : 0;
			
			var bullet:Bullet = new Bullet();
			bullet.speed = 400;
			bullet.shoot(new FlxPoint(x+_weaponOffset.x, y+_weaponOffset.y), angle);
			Reg.bullets.add(bullet);
			_fireCoolDown = 10;
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		movement();
		shoot();
		for (quest in quests)
			quest.updateQuest();
		_fireCoolDown -= 1;
		
		var quest:Quest = quests[Quest.findIndexByID(quests, activeQuestID)];
		if (quest.finished)
			quest.getReward(this);
		super.update(elapsed);
	}
}