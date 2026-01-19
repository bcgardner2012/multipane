extends TextureRect
class_name Deck

signal start_game()
signal deck_clicked() # only use this after the game has been started

var game_in_progress: bool

@export var has_post_start_functionality: bool = false

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		if not game_in_progress:
			game_in_progress = true
			start_game.emit()
		elif has_post_start_functionality:
			deck_clicked.emit()

# as in AI brain
func _on_brain_game_started() -> void:
	if not game_in_progress:
		game_in_progress = true
		start_game.emit()

# wire decks together when multiple can start the game
func _on_other_deck_start_game() -> void:
	game_in_progress = true
