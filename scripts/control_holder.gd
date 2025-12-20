extends Control
class_name ControlHolder

func _on_folder_selector_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		visible = !visible
