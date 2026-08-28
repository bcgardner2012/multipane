extends WarningsHolder
class_name CardCaptureWarnings

func _on_card_capture_game_player_error_game_over() -> void:
	_show_warning($GameOver)


func _on_card_capture_game_player_error_mixed_suit() -> void:
	_show_warning($MixedSuitError)


func _on_card_capture_game_player_error_no_cards_selected() -> void:
	_show_warning($NoCardsSelectedError)


func _on_card_capture_game_player_error_sum_too_low() -> void:
	_show_warning($SumTooLowError)


func _on_card_capture_game_player_error_too_many_selected() -> void:
	_show_warning($TooManyCardsError)


func _on_card_capture_game_player_error_two_jokers() -> void:
	_show_warning($TwoJokersError)
