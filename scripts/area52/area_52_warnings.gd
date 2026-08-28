extends WarningsHolder
class_name Area52Warnings

func _on_area_52_game_player_invalid_color_played() -> void:
	_hide_all_children()
	$ColorInvalid.visible = true
	warning_displayed = true


func _on_area_52_game_player_invalid_sacrifice_played() -> void:
	_hide_all_children()
	$SacrificeInvalid.visible = true
	warning_displayed = true


func _on_area_52_game_player_invalid_sum_played() -> void:
	_hide_all_children()
	$SumInvalid.visible = true
	warning_displayed = true


func _on_area_52_game_player_too_few_humans_played() -> void:
	_hide_all_children()
	$TooFewHumans.visible = true
	warning_displayed = true


func _on_area_52_game_player_too_low_single_rank_played() -> void:
	_hide_all_children()
	$RankTooLow.visible = true
	warning_displayed = true


func _on_area_52_game_player_too_many_humans_played() -> void:
	_hide_all_children()
	$TooManyHumans.visible = true
	warning_displayed = true
