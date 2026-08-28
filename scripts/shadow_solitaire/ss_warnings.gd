extends WarningsHolder
class_name SSWarnings


func _on_shadow_solitaire_game_player_invalid_selection() -> void:
	_show_warning($InvalidSelection)


func _on_shadow_solitaire_game_player_player_died() -> void:
	_show_warning($PlayerDied)


func _on_shadow_solitaire_game_player_player_won() -> void:
	_show_warning($PlayerWon)
