package;

import flixel.FlxG;
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
import haxe.io.Path;
import lime.project.Haxelib;
import TiledLevel;
import Player;

class PlayState extends FlxState
{
	private var _map:TiledLevel;
	private var _player:Player;
	
	override public function create():Void
	{
		_map = new TiledLevel(AssetPaths.test__tmx);
		add(_map.background);
		for (layer in _map.tileLayers)
		{
			add(layer);
		}
		
		var playerSpawn = _map.playerSpawn;
		_player = new Player(playerSpawn.x, playerSpawn.y);
		add(_player);
		
		FlxG.camera.follow(_player, TOPDOWN, 1);
		FlxG.camera.setScrollBoundsRect(0, 0, _map.fullWidth, _map.fullHeight);
		FlxG.worldBounds.set(0, 0, _map.fullWidth, _map.fullHeight);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		for (collideLayerID in _map.collideLayersID)
		{
			FlxG.collide(_player, _map.tileLayers[collideLayerID]);
		}
	}
}