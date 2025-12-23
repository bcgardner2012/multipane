extends TextureRect
class_name Deck

signal start_game()

var game_in_progress: bool

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		if not game_in_progress:
			game_in_progress = true
			start_game.emit()

func _on_brain_game_started() -> void:
	if not game_in_progress:
		game_in_progress = true
		start_game.emit()


func _on_other_deck_start_game() -> void:
	game_in_progress = true
