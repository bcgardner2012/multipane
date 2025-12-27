extends TextureRect
class_name CardHighlighter

@export var default_texture: Texture2D
@export var highlight_texture: Texture2D


func _on_card_use_card(_data: CardData, button_index: int) -> void:
	if button_index == MOUSE_BUTTON_LEFT:
		texture = highlight_texture
	elif button_index == MOUSE_BUTTON_RIGHT:
		texture = default_texture

func _trigger_highlight(card: CardData) -> void:
	if card.equals(get_child(0).data):
		texture = highlight_texture

func _unhighlight() -> void:
	texture = default_texture
