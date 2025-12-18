extends TextEdit
class_name Notes


func _on_notes_tool_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		visible = !visible
