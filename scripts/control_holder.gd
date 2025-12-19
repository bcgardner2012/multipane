extends Control
class_name ControlHolder

func _on_folder_selector_tool_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		visible = !visible
