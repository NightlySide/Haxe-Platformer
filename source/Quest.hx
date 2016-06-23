package;
import haxe.Json;
import openfl.Assets;

class Quest
{
	public var title:String;
	public var id:Int;
	public var objectives:Array<Objective>;
	public var finished:Bool = false;
	public var rewardGold:Int;
	public var rewardExp:Float;
	private var _rewardTaken:Bool = false;
	
	public function new(fileName:String) 
	{
		objectives = new Array<Objective>();
		
		var value = Assets.getText("assets/data/quests/"+fileName+".json"),
        json = Json.parse(value);
		
		title = json.title;
		id = Std.parseInt(json.id);
		for (tId in Reflect.fields(json.objectives))
		{
			var obj:Objective = new Objective(Reflect.field(json.objectives, tId));
			objectives.push(obj);
		}
		for (rew in Reflect.fields(json.rewards))
		{
			switch(rew.toLowerCase())
			{
				case "gold":
					rewardGold = Std.parseInt(Reflect.field(json.rewards, rew));
				case "exp":
					rewardExp = Std.parseFloat(Reflect.field(json.rewards, rew));
			}
		}
	}
	
	public function updateQuest()
	{
		var allDone:Bool = true;
		for (obj in objectives)
			if (!obj.finished)
				allDone = false;
		if (allDone)
			finished = true;
	}
	
	public function getReward(player:Player)
	{
		if (!_rewardTaken)
		{
			player.money += rewardGold;
			player.exp += rewardExp;
			_rewardTaken = true;
		}
	}
	
	static public function findIndexByID(quests:Array<Quest>, id:Int)
	{
		for (q in quests)
		{
			if (q.id == id)
				return quests.indexOf(q);
		}
		return 0;
	}
	
}

class Objective 
{
	public var type:ObjectiveType;
	public var finished:Bool = false;
	public var target:String;
	public var quantity:Int = 1;
	
	private var _startingCount:Int;
	public var _count:Int = 0;
	
	public function new(arg:Array<String>)
	{
		switch(arg[0].toLowerCase())
		{
			case "kill":
				type = ObjectiveType.KILL;
				_startingCount = Reg.enemiesKilled.get(Enemy.getEnemyTypeByString(arg[1]));
			case "pickup":
				type = ObjectiveType.PICKUP;
			case "talk":
				type = ObjectiveType.TALK;
		}
		target = arg[1];
		if (type == ObjectiveType.KILL || type == ObjectiveType.PICKUP)
			quantity = Std.parseInt(arg[2]);
	}
	
	public function isDone():Bool
	{
		switch(type)
		{
			case ObjectiveType.KILL:
				_count = Reg.enemiesKilled.get(Enemy.getEnemyTypeByString(target));
				if (_count-_startingCount >= quantity)
				{
					finished = true;
					return true;
				}
			case ObjectiveType.TALK:
				if (Reg.npcTalkedTo.get(NPC.getNPCByID(Std.parseInt(target))))
				{
					finished = true;
					return true;
				}
			case ObjectiveType.PICKUP:
				return false;
		}
		return false;
	}
	
	public function repr():String
	{
		switch(type)
		{
			case ObjectiveType.TALK:
				var name = NPC.getNPCByID(Std.parseInt(target)).name;
				return "Talk to : "+name;
			case ObjectiveType.KILL:
				return "Kill : "+Std.string(_count-_startingCount)+"/"+Std.string(quantity)+" "+target;
			case ObjectiveType.PICKUP:
				return "Get : "+Std.string(quantity)+" "+target;
		}
	}
}

enum ObjectiveType {
	KILL;
	PICKUP;
	TALK;
}