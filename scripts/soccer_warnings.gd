extends WarningsHolder
class_name SoccerWarnings


func _on_soccer_game_player_final_half_started() -> void:
	_show_warning($FinalHalf)


func _on_soccer_game_player_player_lost() -> void:
	_show_warning($PlayerLost)


func _on_soccer_game_player_player_won() -> void:
	_show_warning($PlayerWon)


func _on_soccer_game_player_tied() -> void:
	_show_warning($Tied)
