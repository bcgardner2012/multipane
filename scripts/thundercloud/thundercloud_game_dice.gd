extends HBoxContainer
class_name ThundercloudGameDice

@export var color: Color # exported so we can set a default

func _ready() -> void:
	set_color(color)

# roll all child dice
func roll() -> Array[int]:
	var arr: Array[int] = []
	for child in get_children():
		if child.visible:
			var d6 = child as D6
			arr.append(d6.roll())
	return arr

func set_color(_color: Color) -> void:
	color = _color
	for child in get_children():
		var d6 = child as D6
		d6.self_modulate = color

# pass the number of 1s rolled
func hide_dice(count: int) -> void:
	var _hidden = 0
	for child in get_children():
		if child.visible:
			child.visible = false
			_hidden += 1
			if _hidden == count:
				break

func show_all() -> void:
	for child in get_children():
		child.visible = true
