extends Sprite2D

@onready var _HPBar: TextureProgressBar = $HealthBar
var Player: PlayerCharacter

var maxHP: float
var curHP: float

func _ready():
	await get_tree().process_frame
	getPlayerData()

func getPlayerData():
	Player = get_tree().get_nodes_in_group("thePlayer")[0]
	if Player:
		initialSetHP(Player.curHealth , Player.MaxHealth )
		Player.HPChanged.connect(HPChange)
		
func initialSetHP(_curHP: float, _maxHP: float):
	maxHP = _maxHP
	curHP = _curHP
	_HPBar.value = abs(curHP/maxHP) * 100

func HPChange(newCurHP : float, newMaxHP: float):
	_HPBar.value = abs(newCurHP/maxHP) * 100
	#print(abs(newCurHP/maxHP) * 100)
