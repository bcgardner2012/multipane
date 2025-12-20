extends TextureRect
class_name Card

signal use_card(data: CardData, button_index: int)

var data: CardData
var original_texture: Texture2D

func _ready() -> void:
	original_texture = texture

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event) or ClickHelper.is_right_click(event):
		if data != null:
			reset_texture_and_emit(event.button_index)

func set_card_data(card_data: CardData) -> void:
	data = card_data
	texture = data.texture


func _on_ai_brains_play_card(card: CardData, button: int) -> void:
	if data != null and card != null and card.equals(data):
		reset_texture_and_emit(button)

func reset_texture_and_emit(button: int) -> void:
	var tmp = data
	data = null
	texture = original_texture
	use_card.emit(tmp, button)
