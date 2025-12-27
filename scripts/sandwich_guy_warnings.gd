extends WarningsHolder
class_name SandwichGuyWarnings


func _on_sandwich_guy_game_player_not_equidistant_ranks() -> void:
	_hide_all_children()
	$UnequalDistance.visible = true
	warning_displayed = true


func _on_sandwich_guy_game_player_too_few_cards() -> void:
	_hide_all_children()
	$WrongCardCount.visible = true
	warning_displayed = true


func _on_sandwich_guy_game_player_too_many_cards() -> void:
	_hide_all_children()
	$WrongCardCount.visible = true
	warning_displayed = true
