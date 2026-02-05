extends Panel
class_name OutlawKeepArea

@export var roll_area: OutlawRollArea

func move_dice_to_roll_area() -> void:
	for child in get_children():
		if child is D6:
			child.reparent(roll_area, false)

func get_dice_total() -> int:
	var total = 0
	for child in get_children():
		if child is D6:
			total += child.value
	return total
