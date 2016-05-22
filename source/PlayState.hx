package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import haxe.io.Path;
import lime.project.Haxelib;
import TiledLevel;
import Player;
import Enemy;
import HUD;

class PlayState extends FlxState
{
	private var _map:TiledLevel;
	private var _player:Player;
	private var _hud:HUD;
	private var _objects:FlxGroup;
	private var _hazards:FlxGroup;
	
	override public function create():Void
	{
		Reg.init();
		
		_map = new TiledLevel(AssetPaths.test__tmx);
		add(_map.background);
		for (layer in _map.tileLayers)
		{
			add(layer);
		}
		
		var playerSpawn = _map.playerSpawn;
		_player = new Player(playerSpawn.x, playerSpawn.y);
		add(_player);
		
		for (enemy in _map.enemiesSpawn)
		{
			var enemy:Enemy = new Enemy(enemy.x, enemy.y);
			enemy.init(enemy.x, enemy.y, _player);
			Reg.enemies.add(enemy);
		}
		
		add(Reg.enemies);
		add(Reg.bullets);
		add(Reg.enemyBullets);
		
		_objects = new FlxGroup();
		_objects.add(_player);
		_objects.add(Reg.enemies);
		_objects.add(Reg.bullets);
		_objects.add(Reg.enemyBullets);
		
		_hazards = new FlxGroup();
		_hazards.add(Reg.enemies);
		_hazards.add(Reg.enemyBullets);
		
		_hud = new HUD(_player);
		add(_hud);
		
		FlxG.camera.follow(_player, TOPDOWN, 1);
		FlxG.camera.setScrollBoundsRect(0, 0, _map.fullWidth, _map.fullHeight);
		FlxG.worldBounds.set(0, 0, _map.fullWidth, _map.fullHeight);
		FlxG.camera.fade(0xff000000, 1, true);
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		_hud.updateHUD();
		_map.collideWithLevel(_objects);
		
		FlxG.overlap(Reg.bullets, _hazards, shootHazardsOverlapHandler);
		FlxG.overlap(_hazards, _player, hazardOverlapHandler);
		
		for (enemy in Reg.enemies)
		{
			enemy.updateDetection();
			enemy.movement();
		}
	}
	
	public function shootHazardsOverlapHandler(playerBullet:Bullet, hazard:FlxObject):Void 
	{
		if (!Std.is(hazard, Bullet) && playerBullet.alive)
		{
			playerBullet.kill();
			hazard.hurt(playerBullet.damage);
		}
	}
	
	public function hazardOverlapHandler(hazard:FlxObject, player:FlxObject)
	{
		if (Std.is(hazard, Bullet)) 
		{
			var enemyBullet:Bullet = cast hazard;
			enemyBullet.kill();
			
			player.hurt(enemyBullet.damage);
		}
		else if (Std.is(hazard, Enemy) && Std.is(player, Player)) 
		{
			var enemy:Enemy = cast hazard;
			//player.hurt(1);
		}
	}
}