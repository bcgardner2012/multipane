extends Control
class_name Settings

# The only thing really shared is response to the gear icon click.

var game_in_progress: bool

func _on_settings_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event) and not game_in_progress:
		visible = !visible
