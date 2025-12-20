extends TextureButton
class_name ScoundrelRunButton

# there are no cards left. Running will crash the game after victory
func _on_scoundrel_game_victory() -> void:
	visible = false
