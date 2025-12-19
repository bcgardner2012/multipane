extends TextureRect
class_name Deck

signal start_game()

var game_in_progress: bool

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not game_in_progress:
			game_in_progress = true
			start_game.emit()
