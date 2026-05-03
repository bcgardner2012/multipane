extends WarningsHolder
class_name CarrionEaterWarningsHolder

const INSTRUCTION_TTL = 30.0

func _on_carrion_eater_game_player_multiple_dice_rolled() -> void:
	_show_warning($SelectActionDie, INSTRUCTION_TTL)


func _on_action_dice_action_die_selected() -> void:
	hide_all()


func _on_carrion_eater_game_player_player_won() -> void:
	_show_warning($PlayerWon)
