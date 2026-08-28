extends WarningsHolder
class_name SnakeCharmerWarningsHolder


func _on_snake_charmer_game_player_red_won() -> void:
	_show_warning($RedWon)


func _on_snake_charmer_game_player_green_won() -> void:
	_show_warning($GreenWon)


func _on_snake_charmer_game_player_blue_won() -> void:
	_show_warning($BlueWon)
