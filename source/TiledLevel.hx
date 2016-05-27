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
import Portal;

class TiledLevel extends TiledMap
{
	public var foregroundTileLayers:Array<FlxTilemap>; 
	public var backgroundTileLayers:Array<FlxTilemap>; 
	public var collidableTileLayers:Array<FlxTilemap>;
	public var playerSpawn:FlxPoint;
	public var enemiesSpawn:Array<FlxPoint>;
	public var npcs:FlxTypedGroup<NPC>;
	public var portals:Map<String, Portal>;
	public var background:FlxSprite;
	
	private var _isBackground:Bool = true;
	
	public function new(data:FlxTiledAsset) 
	{
		super(data);
		
		foregroundTileLayers = new Array<FlxTilemap>();
		backgroundTileLayers = new Array<FlxTilemap>();
		enemiesSpawn = new Array<FlxPoint>();
		npcs = new FlxTypedGroup<NPC>();
		portals = new Map<String, Portal>();
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
				
				if(_isBackground)
					backgroundTileLayers.push(tileMap);
				else
					foregroundTileLayers.push(tileMap);
				
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
							var id = Std.parseInt(object.properties.get("id"));
							var text = object.properties.get("text");
							var pos = new FlxPoint(object.x, object.y);
							var sprite:String = "assets/images/" + object.properties.get("sprite") + ".png";
							var npc = new NPC(pos.x, pos.y, id, name, text, sprite);
							npcs.add(npc);
							
						case "Portal":
							var name = object.name;
							var target = object.properties.get("link");
							var portal = new Portal(object.x, object.y);
							var exit = (object.properties.get("exit") == "left") ? FlxObject.LEFT : FlxObject.RIGHT;
							var changeMap = object.properties.get("changeMap");
							if (changeMap != null)
							{
								portal.changeMap = true;
								portal.link = changeMap;
								portals.set(name, portal);
							}
							else {
								portal.changeMap = false;
								portal.link = target;
								portal.exit = exit;
								portals.set(name, portal);
							}
							
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