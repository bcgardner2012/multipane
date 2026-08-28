extends Settings
class_name CarrionEaterSettings

# shouldn't do static, closing and reopening could screw with state
var is_stamina_enabled: bool

func _on_add_stamina_check_box_toggled(toggled_on: bool) -> void:
	is_stamina_enabled = toggled_on


func _on_board_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		visible = false
		game_in_progress = true
