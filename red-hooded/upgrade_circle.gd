extends Area2D
@export var Item : PackedScene

signal UpgradeReceived(PackedScene)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		UpgradeReceived.emit(Item)
		
func Upgrade() -> PackedScene:
	return Item
