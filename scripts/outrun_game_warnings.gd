extends WarningsHolder
class_name OutrunGameWarnings

func _on_outrun_game_player_error_blue_dead() -> void:
	_show_warning($BlueDeadError)


func _on_outrun_game_player_error_red_dead() -> void:
	_show_warning($RedDeadError)


func _on_outrun_game_player_game_over() -> void:
	_show_warning($GameOver)
