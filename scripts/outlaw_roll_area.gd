extends Panel
class_name OutlawRollArea

@export var keep_area: OutlawKeepArea

# roll dice remaining in my area
func reroll() -> void:
	for child in get_children():
		if child is D6:
			var d6 = child as D6
			d6.roll()

func move_dice_to_keep_area() -> void:
	for child in get_children():
		if child is D6:
			child.reparent(keep_area, false)
