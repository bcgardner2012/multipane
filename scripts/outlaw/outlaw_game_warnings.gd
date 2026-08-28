extends WarningsHolder
class_name OutlawGameWarnings

func _on_outlaw_game_player_error_too_few_dice_claimed() -> void:
	_show_warning($TooFewDiceClaimed)


func _on_outlaw_game_player_player_lost() -> void:
	_show_warning($YouLose)


func _on_outlaw_game_player_player_won() -> void:
	_show_warning($YouWin)
