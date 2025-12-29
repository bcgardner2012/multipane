extends WarningsHolder
class_name EmissaryWarnings

func _on_emissary_game_player_invalid_card_play() -> void:
	_show_warning($MustPlaySameSuit)


func _on_emissary_game_player_jack_out_of_phase() -> void:
	_show_warning($JackOutOfPhase)


func _on_emissary_game_player_no_clubs_in_hand_error() -> void:
	_show_warning($NoClubsInHand)


func _on_emissary_game_player_same_kingdom_spades_error() -> void:
	_show_warning($SelectedSameKingdom)


func _on_emissary_game_player_last_kingdom_spades_error() -> void:
	_show_warning($LastKingdom)
