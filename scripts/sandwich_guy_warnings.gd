extends WarningsHolder
class_name SandwichGuyWarnings


func _on_sandwich_guy_game_player_not_equidistant_ranks() -> void:
	_show_warning($UnequalDistance)


func _on_sandwich_guy_game_player_too_few_cards() -> void:
	_show_warning($WrongCardCount)


func _on_sandwich_guy_game_player_too_many_cards() -> void:
	_show_warning($WrongCardCount)
