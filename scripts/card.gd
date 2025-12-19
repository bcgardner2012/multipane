extends TextureRect
class_name Card

signal use_card(data: CardData, button_index: int)

var data: CardData
var original_texture: Texture2D

func _ready() -> void:
	original_texture = texture

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) and event.pressed:
		if data != null:
			var tmp = data
			data = null
			texture = original_texture
			use_card.emit(tmp, event.button_index)

func set_card_data(card_data: CardData) -> void:
	data = card_data
	texture = data.texture
