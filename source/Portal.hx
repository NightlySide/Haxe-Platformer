package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Portal extends FlxSprite
{
	public var link:String;
	public var name:String;
	public var exit:Int;
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.portal__png, true, 64, 64);
		width = 32;
		height = 64;
		
		var flipped:Bool = (exit == FlxObject.RIGHT);
		animation.add("idle", [0, 1, 2, 3], 12, true, flipped);
		animation.play("idle", false, false, Reg.random.int(0, 3));
	}
	
	public function getExit():FlxPoint
	{
		var offset = (exit == FlxObject.LEFT) ? -32 : 32; 
		return new FlxPoint(x +	offset, y);
	}
	
}