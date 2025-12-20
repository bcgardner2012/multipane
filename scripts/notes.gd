extends TextEdit
class_name Notes


func _on_notes_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		visible = !visible
