extends TextureRect
class_name Card

signal use_card(data: CardData, button_index: int)

@export var should_wipe_texture_on_click: bool = true
@export var should_wipe_data_on_click: bool = true

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
	if should_wipe_data_on_click:
		data = null
	if should_wipe_texture_on_click:
		texture = original_texture
	use_card.emit(tmp, button)

func reset_texture() -> void:
	texture = original_texture

func reset_texture_and_data() -> void:
	texture = original_texture
	data = null
