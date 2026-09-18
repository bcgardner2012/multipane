extends WarningsHolder
class_name DiceFishingWarnings


func _on_dice_fishing_game_player_game_over() -> void:
	_show_warning($GameOver)


func _on_dice_fishing_game_player_game_won() -> void:
	_show_warning($GameWon)


func _on_dice_fishing_game_player_unused_triple_error() -> void:
	_show_warning($UnusedTripleError)
