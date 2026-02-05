extends TextureRect
class_name D6

signal d6_entered_tree(node: D6)
signal left_clicked(node: D6)

var value: int

func roll() -> int:
	var r = (randi() % 6) + 1
	value = r
	var side = get_child(r - 1) as DieSide
	texture = side.get_random_sprite()
	return value


func _on_tree_entered() -> void:
	d6_entered_tree.emit(self)


func _on_gui_input(event: InputEvent) -> void:
	if (ClickHelper.is_left_click(event)):
		left_clicked.emit(self)
