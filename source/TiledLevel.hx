package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledMap.FlxTiledAsset;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.graphics.frames.FlxImageFrame;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tile.FlxTilemap;
import haxe.io.Path;

class TiledLevel extends TiledMap
{
	public var tileLayers:Array<FlxTilemap>; 
	public var collidableTileLayers:Array<FlxTilemap>;
	public var playerSpawn:FlxPoint;
	public var enemiesSpawn:Array<FlxPoint>;
	public var npcs:Map<String, FlxPoint>;
	public var npcsText:Map<String, String>;
	public var background:FlxSprite;
	
	public function new(data:FlxTiledAsset) 
	{
		super(data);
		
		tileLayers = new Array<FlxTilemap>();
		enemiesSpawn = new Array<FlxPoint>();
		npcs = new Map<String, FlxPoint>();
		npcsText = new Map<String, String>();
		collidableTileLayers = new Array<FlxTilemap>();
		
		
		for (layer in layers)
		{
			if (layer.type == TiledLayerType.TILE)
			{
				var tileLayer:TiledTileLayer = cast layer;
				var tileSetName:String = tileLayer.properties.get("tileset");
				var tileSet:TiledTileSet = getTileSet(tileSetName);
				var imagePath:Path = new Path(tileSet.imageSource);
				var processedPath:String = "assets/images/" + imagePath.file + "." + imagePath.ext;
				var isColliding:String = tileLayer.properties.get("collide");
				
				var tileMap = new FlxTilemap();
				tileMap.width = width;
				tileMap.height = height;
				tileMap.loadMapFromCSV(tileLayer.csvData, processedPath, tileSet.tileWidth, tileSet.tileHeight, null, 1, 1, 1);

				tileLayers.push(tileMap);
				
				if (isColliding == "1")
					collidableTileLayers.push(tileMap);
			}
			else if (layer.type == TiledLayerType.OBJECT)
			{
				var objectLayer:TiledObjectLayer = cast layer;
				for (object in objectLayer.objects)
				{
					switch(object.type)
					{
						case "PlayerSpawn":
							playerSpawn = new FlxPoint(object.x, object.y);
						case "Enemy":
							enemiesSpawn.push(new FlxPoint(object.x, object.y));
						case "NPC":
							var name = object.name;
							var text = object.properties.get("text");
							var pos = new FlxPoint(object.x, object.y);
							npcs.set(name, pos);
							npcsText.set(name, text);
					}
				}
			}
			else if (layer.type == TiledLayerType.IMAGE)
			{
				var imageLayer:TiledImageLayer = cast layer;
				var imagePath:Path = new Path(imageLayer.imagePath);
				var processedPath:String = "assets/images/" + imagePath.file + "." + imagePath.ext;
				var pos:FlxPoint = new FlxPoint(Std.parseFloat(imageLayer.properties.get("x")), Std.parseFloat(imageLayer.properties.get("y")));
				background = new FlxSprite(pos.x, pos.y, processedPath);
			}
		}
	}
	
	public function collideWithLevel(obj:FlxGroup, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers != null)
		{
			for (map in collidableTileLayers)
			{
				return FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
			}
		}
		return false;
	}
}