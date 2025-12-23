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


func _on_area_52_game_player_dual_attack_performed(_humans: Array[CardData], _alien: CardData, _wave: int) -> void:
	_unhighlight()
	var card = get_child(0) as Card
	if not card.data == null and card.data.equals(_alien):
		card.reset_texture_and_data()
	elif _wave > 0 and not card.data == null and (card.data.equals(_humans[0]) or card.data.equals(_humans[1])) and card.data.same_color(_alien):
		card.reset_texture_and_data()

func _unhighlight() -> void:
	texture = default_texture


func _on_area_52_game_player_single_attack_performed(_human: CardData, _alien: CardData) -> void:
	_unhighlight()
	var card = get_child(0) as Card
	if not card.data == null and card.data.equals(_alien):
		card.reset_texture_and_data()
	elif not card.data == null and card.data.equals(_human):
		card.set_card_data(_alien)


func _on_area_52_game_player_sacrifice_performed(_human: CardData, _alien: CardData, _replacement: CardData) -> void:
	_unhighlight()
	var card = get_child(0) as Card
	if not card.data == null and card.data.equals(_alien):
		card.reset_texture_and_data()
	elif not card.data == null and card.data.equals(_human):
		if _replacement != null:
			card.set_card_data(_replacement)
		else:
			card.reset_texture_and_data()

func _on_area_52_game_player_trigger_highlight(card: CardData) -> void:
	if card.equals(get_child(0).data):
		texture = highlight_texture
