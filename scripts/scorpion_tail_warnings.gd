extends WarningsHolder
class_name ScorpionTailWarnings


func _on_scorpion_tail_game_player_must_play_lower_rank() -> void:
	_show_warning($LowerOnlyError)


func _on_scorpion_tail_game_player_tail_cannot_start_with_ace() -> void:
	_show_warning($InvalidStartError)
