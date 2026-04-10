# dmgNumberPool.gd
extends Node

const dmgTxtCount: int = 650
const LabelCount_poolPos: Vector2 = Vector2(1512,-258)
var blank_DmgTxt: Array [DamageNumberText]
@onready var blank_DmgNumber: PackedScene = preload("res://(4) Global Scripts/DmgNumber.tscn")

func _ready():
	await get_tree().process_frame
	build_pool()
	
func build_pool():
	for count in range(dmgTxtCount):
		var newblank : DamageNumberText = blank_DmgNumber.instantiate()
		add_child(newblank)
		newblank.visible = false
		newblank.process_mode = Node.PROCESS_MODE_DISABLED
		newblank.DmgNumber_returned_toPool.connect(return_to_pool)
		newblank.z_index = ZIndex_constants.UI
		newblank.global_position = LabelCount_poolPos

		blank_DmgTxt.append(newblank)

func return_to_pool(_DmgNum: DamageNumberText):
	_DmgNum.process_mode = Node.PROCESS_MODE_DISABLED
	_DmgNum.global_position = LabelCount_poolPos
	blank_DmgTxt.append(_DmgNum)


func put_DmgNumber_toSmallEnemies(_target: Node2D,_dmgAmount: int) -> DamageNumberText:
	var newDmgNumber: DamageNumberText = blank_DmgTxt.pop_back()
	if newDmgNumber:
		newDmgNumber.process_mode = Node.PROCESS_MODE_INHERIT
		newDmgNumber.latch(_target) # if target isnt in damagedState, latch the dmg number
		newDmgNumber.activate(_dmgAmount)
		return newDmgNumber
	else:
		push_error("Ran out of Dmg Numbers")
		return null
	
