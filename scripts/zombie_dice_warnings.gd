extends WarningsHolder
class_name ZombieDiceWarnings


func _on_zombie_dice_game_player_hit_three_times() -> void:
	_show_warning($HitThreeTimes)


func _on_zombie_dice_game_player_game_won() -> void:
	_show_warning($GameWon)


func _on_zombie_dice_game_player_game_lost() -> void:
	_show_warning($GameLost)
