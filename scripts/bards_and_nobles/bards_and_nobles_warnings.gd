extends WarningsHolder
class_name BardsAndNoblesWarnings


func _on_bards_and_nobles_game_player_no_cards_selected_error() -> void:
	_show_warning($NoCardsSelected)


func _on_bards_and_nobles_game_player_wrong_value_error() -> void:
	_show_warning($OfferValueDoesNotMatch)


func _on_bards_and_nobles_game_game_over(score: int) -> void:
	if score < 7:
		_show_warning($Terminated)
	elif score == 7 or score == 8:
		_show_warning($EmployeeOfMonth)
	elif score == 9 or score == 10:
		_show_warning($PerformanceBonus)
	elif score == 11 or score == 12:
		_show_warning($Promotion)
	elif score == 13 or score == 14:
		_show_warning($CompanyStake)
	elif score > 14:
		_show_warning($Executive)
