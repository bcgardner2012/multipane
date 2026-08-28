extends TextureButton
class_name SSBombButton

signal bomb_toggled()

@export var original_texture: Texture2D
@export var lit_texture: Texture2D

func _on_pressed() -> void:
	if texture_normal == original_texture:
		texture_normal = lit_texture
	else:
		reset()
	bomb_toggled.emit()

func reset() -> void:
	texture_normal = original_texture


func _on_shadow_solitaire_game_player_bomb_used() -> void:
	visible = false


func _on_shadow_solitaire_game_player_new_round_started(_boss: CardData, _health: int) -> void:
	visible = true
	reset()
