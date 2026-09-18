extends VBoxContainer
class_name NudgableDie

signal nudged_up(success: bool, index: int)
signal nudged_down(success: bool, index: int)

@export var index: int

func _on_up_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		var d6 = get_child(1) as D6
		nudged_up.emit(d6.increment() != -1, index)


func _on_down_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		var d6 = get_child(1) as D6
		nudged_down.emit(d6.decrement() != -1, index)

func roll() -> int:
	var d6 = get_child(1) as D6
	return d6.roll()


func _on_disable_nudging() -> void:
	get_child(0).visible = false
	get_child(2).visible = false
