extends WarningsHolder
class_name CarrionEaterWarningsHolder

const INSTRUCTION_TTL = 30.0

var _lost: bool = false

func _on_carrion_eater_game_player_multiple_dice_rolled() -> void:
	if not _lost:
		_show_warning($SelectActionDie, INSTRUCTION_TTL)


func _on_action_dice_action_die_selected() -> void:
	hide_all()


func _on_carrion_eater_game_player_player_won() -> void:
	_show_warning($PlayerWon)


func _on_carrion_eater_game_player_player_lost() -> void:
	_lost = true
	_show_warning($PlayerLost)
