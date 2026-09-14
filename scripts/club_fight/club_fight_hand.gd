extends HBoxContainer
class_name ClubFightHand

signal select_card(card: CardData)
signal deselect_card()

var selected_card: CardData

# find next invisible card, update and show it
func show_cards(cards: Array[CardData]) -> void:
	for i in range(0, cards.size()):
		var ch = get_child(i) as CardHighlighter
		if cards[i] == null:
			ch.get_child(0).reset_texture_and_data()
		else:
			ch.get_child(0).set_card_data(cards[i])
		ch.visible = true
	for i in range(cards.size(), get_child_count()):
		var ch = get_child(i).get_child(0).reset_texture_and_data()
		ch.visible = false

func _on_card_use_card(data: CardData, button_index: int) -> void:
	if selected_card == null:
		if button_index == MOUSE_BUTTON_LEFT:
			selected_card = data
			select_card.emit(data)
	elif button_index == MOUSE_BUTTON_RIGHT and selected_card == data:
		selected_card = null
		deselect_card.emit()

func deselect() -> void:
	selected_card = null
	for child in get_children():
		var ch = child as CardHighlighter
		ch._unhighlight()
