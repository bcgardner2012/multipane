extends GamePane
class_name SandwichGuyGamePane

# quality can be 0-2: different colors, same color, same suit
signal sandwich_served(quality: int)


func _on_sandwich_guy_game_player_sandwich_served(_sandwich: Array[CardData], quality: int) -> void:
	sandwich_served.emit(quality)
