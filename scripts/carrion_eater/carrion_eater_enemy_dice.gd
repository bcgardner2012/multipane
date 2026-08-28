extends Control
class_name CarrionEaterEnemyDice

signal do_respawn()

func init_dice() -> void:
	visible = true
	for child in get_children():
		var d6 = child as D6
		d6.set_value(6)

# @return 0 = success, 1 = success and killed, -1 = invalid target
func take_damage(index: int) -> int:
	var target = get_child(index) as D6
	if target.visible and target.value > 1:
		target.decrement()
		return 0
	elif target.visible and target.value <= 1:
		target.visible = false
		return 1
	return -1

# if enemy can't heal b/c max health, respawn
func heal(index: int) -> void:
	if index < 0 or index > 4:
		return
	
	var target = get_child(index) as D6
	if target.visible and target.value < 6:
		target.increment()
	elif target.visible and target.value >= 6:
		respawn(1)
		do_respawn.emit()

# nothing ever despawns, rather we just make them invisible and confirm existence
# via visible
func respawn(health: int) -> void:
	for child in get_children():
		var die = child as D6
		if not die.visible:
			die.visible = true
			die.set_value(health)
			return

func won() -> bool:
	for child in get_children():
		if child.visible:
			return false
	return true
