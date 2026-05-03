extends TextureRect
class_name D6

signal d6_entered_tree(node: D6)
signal left_clicked(node: D6)

var value: int

func roll() -> int:
	var r = (randi() % 6) + 1
	value = r
	_set_semi_random_texture()
	return value

# can't exceed 6, return -1 if this would exceed 6
func increment() -> int:
	if (value == 6):
		return -1
	value = value + 1
	_set_semi_random_texture()
	return value

# can't go below 1, return -1 if would violate
func decrement() -> int:
	if (value == 1):
		return -1
	value = value - 1
	_set_semi_random_texture()
	return value

func set_value(v: int) -> void:
	value = v
	_set_semi_random_texture()

func _on_tree_entered() -> void:
	d6_entered_tree.emit(self)


func _on_gui_input(event: InputEvent) -> void:
	if (ClickHelper.is_left_click(event)):
		left_clicked.emit(self)

func _set_semi_random_texture() -> void:
	var side = get_child(value - 1) as DieSide
	texture = side.get_random_sprite()
