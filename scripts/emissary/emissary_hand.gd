extends HBoxContainer
class_name EmissaryHand


func _on_emissary_game_player_card_played_from_hand(card: CardData) -> void:
	# find child with this card and nullify data and hide holder
	for card_holder in get_children():
		var card_node = card_holder.get_child(0) as Card
		if card.equals(card_node.data):
			card_node.reset_texture_and_data()
			card_holder.reset_and_hide()
			break


func _on_emissary_game_player_diamond_advisor_used(drawn_cards: Array[CardData]) -> void:
	var unused_card_holders = _get_unused_card_holders(drawn_cards.size())
	_populate_unused_card_holders(unused_card_holders, drawn_cards)


func _on_emissary_game_player_do_diamond_discard(discards: Array[CardData]) -> void:
	for card_holder in get_children():
		var card = card_holder.get_child(0) as Card
		_discard_if(card_holder, discards[0].equals(card.data) or discards[1].equals(card.data))


func _on_emissary_game_player_club_advisor_used(drawn_cards: Array[CardData]) -> void:
	var unused_card_holders = _get_unused_card_holders(drawn_cards.size())
	_populate_unused_card_holders(unused_card_holders, drawn_cards)

func _get_unused_card_holders(need: int) -> Array[CardHighlighter]:
	var unused_card_holders: Array[CardHighlighter] = []
	for child in get_children():
		if not child.visible:
			unused_card_holders.append(child)
			if unused_card_holders.size() == need:
				break
	return unused_card_holders

func _populate_unused_card_holders(unused: Array[CardHighlighter], drawn_cards: Array[CardData]) -> void:
	for i in range(0, drawn_cards.size()):
		unused[i].visible = true
		unused[i]._unhighlight()
		var unused_card = unused[i].get_child(0) as Card
		unused_card.set_card_data(drawn_cards[i])


func _on_emissary_game_player_heart_advisor_used(to_remove: Array[CardData]) -> void:
	for rem in to_remove:
		for card_holder in get_children():
			var card = card_holder.get_child(0) as Card
			_discard_if(card_holder, rem.equals(card.data))

func _discard_if(card_holder: Control, condition: bool) -> void:
	var card = card_holder.get_child(0) as Card
	if condition:
		card.reset_texture_and_data()
		card_holder._unhighlight()
		card_holder.visible = false
