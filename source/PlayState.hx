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
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
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
	private var _teleportCoolDown:Float = 0;
	
	override public function create():Void
	{		
		//FlxG.debugger.drawDebug = true;
		_map = new TiledLevel(Reg.mapPath);
		
		var playerSpawn = _map.playerSpawn;
		_player = new Player();
		_player.setPosition(playerSpawn.x, playerSpawn.y);
		
		loadLayersAndEntities(_map, _player);
		
		add(Reg.bullets);
		add(Reg.enemyBullets);
		
		_objects = new FlxGroup();
		_objects.add(Reg.npcs);
		_objects.add(Reg.enemies);
		_objects.add(Reg.enemyBullets);
		_objects.add(Reg.bullets);
		_objects.add(_player);
		
		_hazards = new FlxGroup();
		_hazards.add(Reg.enemies);
		_hazards.add(Reg.enemyBullets);
		
		_hud = new HUD(_player, this);
		add(_hud);
		
		#if mobile
		add(_player.virtualPad);
		#end
		
		FlxG.camera.follow(_player, TOPDOWN, 1);
		FlxG.camera.setScrollBoundsRect(0, 0, _map.fullWidth, _map.fullHeight);
		FlxG.worldBounds.set(0, 0, _map.fullWidth, _map.fullHeight);
		FlxG.camera.fade(0xff000000, 2, true);
		
		super.create();
	}
	
	public function loadLayersAndEntities(map:TiledLevel, player:Player)
	{
		if(_map.background != null)
			add(_map.background);
		for (layer in _map.backgroundTileLayers)
			add(layer);
		
		for (portal in _map.portals.keys())
		{
			Reg.portals.add(_map.portals.get(portal));
		}
		add(Reg.portals);
		
		for (npc in _map.npcs)
		{
			npc.setTalking(false, 0.00001);
			Reg.npcs.add(npc);
			Reg.npcTalkedTo.set(npc, false);
		}	
			
		for (enemy in _map.enemiesSpawn)
		{
			var enemy:Enemy = new Enemy(enemy.x, enemy.y);
			enemy.init(enemy.x, enemy.y, _player);
			Reg.enemies.add(enemy);
		}
		add(Reg.enemies);
		
		add(Reg.npcs);
		add(Reg.npcBubbles);
		
		add(_player);
		
		for (layer in _map.foregroundTileLayers)
			add(layer);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		_hud.updateHUD();
		_map.collideWithLevel(_objects);
		
		FlxG.overlap(Reg.bullets, _hazards, shootHazardsOverlapHandler);
		FlxG.overlap(_hazards, _player, hazardOverlapHandler);
		FlxG.overlap(_player, Reg.npcs, npcOverlapHandler);
		FlxG.overlap(_player, Reg.portals, portalOverlap);
		
		for (enemy in Reg.enemies)
		{
			enemy.updateDetection();
			enemy.movement();
		}
		for (npc in Reg.npcs)
		{
			if (!_player.overlaps(npc))
				npc.setTalking(false);
			//if (_player.getMidpoint().distanceTo(npc.getMidpoint()) <= npc.distanceLook)
			npc.lookAt(_player);
		}
		
		_teleportCoolDown -= 1;
	}
	
	public function shootHazardsOverlapHandler(playerBullet:Bullet, hazard:FlxObject):Void 
	{
		if (!Std.is(hazard, Bullet) && playerBullet.alive)
		{
			playerBullet.kill();
			hazard.hurt(playerBullet.damage);
		}
		_hud.updateQuest();
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
	
	public function npcOverlapHandler(player:Player, npc:NPC)
	{
		npc.setTalking(true);
		Reg.npcTalkedTo.set(npc, true);
		_hud.updateQuest();
	}
	
	public function portalOverlap(player:Player, portal:Portal)
	{
		if (_teleportCoolDown < 0)
		{
			if (!portal.changeMap)
			{
				var target:Portal = _map.portals.get(portal.link);
				var exit:FlxPoint = target.getExit();
				
				FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
				player.setPosition(exit.x, exit.y);
				player.facing = target.exit;
				FlxG.camera.fade(0xff000000, 0.5, true);
			}
			else
			{
				Reg.mapPath = "assets/data/"+portal.link+".tmx";
				
				FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
				Reg.reset();
				FlxG.switchState(new PlayState());
			}
			_teleportCoolDown = 50;
		}
	}
}