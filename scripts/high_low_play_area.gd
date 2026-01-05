extends Control
class_name HighLowPlayArea

@export var brains: Node

var player_count: int

func _ready() -> void:
	player_count = 1

func _on_add_player_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event) and player_count < 4:
		player_count += 1
		if player_count == 2:
			$Player2Controls.visible = true
		elif player_count == 3:
			$Player3Controls.visible = true
		else:
			$Player4Controls.visible = true
