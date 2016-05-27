package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import Player;
import PauseState;
import Quest;

class HUD extends FlxTypedGroup<FlxSprite>
{
	private var _player:Player;
	private var _txtHealth:FlxText;
	private var _sprHealth:FlxSprite;
	private var _txtMoney:FlxText;
	private var _sprMoney:FlxSprite;
	private var _menuButton:FlxButton;
	private var _questTitle:FlxText;
	private var _context:PlayState;
	private var _lines:Array<FlxText>;
	
	public var pauseMenu:PauseState;
	
	public function new(player:Player, context:PlayState) 
	{
		super();
		_player = player;
		_context = context;
		
		_lines = new Array<FlxText>();
		
		_txtHealth = new FlxText(30, 4, 0, Std.string(_player.health) + " / " + Std.string(_player.maxHealth), 16);
        _txtHealth.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		add(_txtHealth);
		
		_sprHealth = new FlxSprite(8, _txtHealth.y + _txtHealth.height/2 - 8, AssetPaths.heart__png);
		//_sprHealth.scale.set(1.5, 1.5);
		add(_sprHealth); 
		
		_txtMoney = new FlxText(_txtHealth.x + _txtHealth.width + 16, 4, 0, Std.string(player.money), 16);
        _txtMoney.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		add(_txtMoney);
		
        _sprMoney = new FlxSprite(_txtHealth.x + _txtHealth.width + 4, _txtMoney.y + (_txtMoney.height/2)  - 4, AssetPaths.coin__png);
		_sprHealth.scale.set(1.5, 1.5);
		add(_sprMoney);
		
		_menuButton = new FlxButton(FlxG.width-79, 0, "Menu", menuClick);
		add(_menuButton);
		
		var activeQuest = player.quests[Quest.findIndexByID(player.quests, player.activeQuestID)];
		_questTitle = new FlxText(0, _menuButton.height + 4, 0, activeQuest.title, 12);
		_questTitle.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		_questTitle.x = FlxG.width - _questTitle.width - 4;
		add(_questTitle);
		
		var offset = 0;
		for (task in activeQuest.objectives)
		{
			var status:String = (task.isDone())? "+": "-";
			var line:FlxText = new FlxText(0, _menuButton.height + _questTitle.height + 4 + offset * 16, 0, "["+status+"] "+task.repr());
			line.x = FlxG.width - _questTitle.width - 4;
			_lines.push(line);
			add(line);
			offset++;
		}
		
		forEach(function(spr:FlxSprite)
		{
			spr.scrollFactor.set(0, 0);
		});
	}
	
	public function updateHUD()
	{
		_txtHealth.text = Std.string(_player.health) + " / " + Std.string(_player.maxHealth);
		_txtMoney.text = Std.string(_player.money);
	}
	
	public function updateQuest()
	{
		var activeQuest = _player.quests[Quest.findIndexByID(_player.quests, _player.activeQuestID)];
		for (k in 0...activeQuest.objectives.length)
		{
			var obj = activeQuest.objectives[k];
			var line = _lines[k];
			var status:String = (obj.isDone())? "+": "-";
			line.text = "["+status+"] "+obj.repr();
		}
	}
	
	public function menuClick()
	{
		var color = FlxColor.fromRGB(0, 0, 0, 200);
		pauseMenu = new PauseState(color);
		_context.openSubState(pauseMenu);
	}
}