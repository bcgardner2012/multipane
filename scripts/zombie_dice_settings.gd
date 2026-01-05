extends Control
class_name ZombieDiceSettings

enum ZombieDiceLoseCondition {
	NONE,
	ROUNDS_PASSED,
	INJURY_COUNT,
	BULLETS_TAKEN
}

static var win_condition_brain_count: int = 13
static var lose_condition: ZombieDiceLoseCondition
static var lose_condition_count: int = 7

@export var injury_label: Label
@export var bullets_label: Label

var game_in_progress: bool

func _on_brain_count_setting_value_changed(value: float) -> void:
	win_condition_brain_count = value as int


func _on_option_button_item_selected(index: int) -> void:
	print("Index " + str(index))
	lose_condition = index as ZombieDiceLoseCondition
	print("LC: " + str(lose_condition))
	if lose_condition == ZombieDiceLoseCondition.INJURY_COUNT:
		injury_label.visible = true
		bullets_label.visible = false
	elif lose_condition == ZombieDiceLoseCondition.BULLETS_TAKEN:
		bullets_label.visible = true
		injury_label.visible = false
	else:
		bullets_label.visible = false
		injury_label.visible = false


func _on_lose_setting_value_changed(value: float) -> void:
	lose_condition_count = value as int


func _on_settings_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event) and not game_in_progress:
		visible = !visible


func _on_human_deck_start_game() -> void:
	game_in_progress = true
	visible = false
