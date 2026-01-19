extends WarningsHolder
class_name JokerJailbreakWarnings


func _on_joker_jailbreak_game_player_sums_invalid_error(_red_sum: int, _black_sum: int) -> void:
	_show_warning($SumsInvalidError)


func _on_joker_jailbreak_game_player_deck_empty_error() -> void:
	_show_warning($DeckEmptyError)


func _on_joker_jailbreak_game_player_cell_full_error() -> void:
	_show_warning($CellFullError)


func _on_joker_jailbreak_game_player_game_won() -> void:
	_show_warning($GameWon)
