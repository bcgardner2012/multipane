extends HBoxContainer
class_name EmissaryKingdoms

# passing kingdom as well may help with future tree navigation
signal kingdom_card_flipped(kingdom: CardData, flipped_card: CardData)

@onready var stacked_card_scene = preload("res://scenes/stacked_card.tscn")

var active_kingdom: CardData

func _on_emissary_game_player_debate_started(kingdom: CardData, drawn_card: CardData) -> void:
	active_kingdom = kingdom
	for card_holder in get_children():
		var card = card_holder.get_child(0) as Card
		if card.data != null and card.data.equals(kingdom):
			# starts face down, should fire signal when flipped
			var stacked_card = stacked_card_scene.instantiate() as Card
			stacked_card.set_card_data(drawn_card)
			stacked_card.card_flipped.connect(_raise_card_flipped)
			card.add_child(stacked_card)

func _raise_card_flipped(flipped_card: CardData, _button_index: int) -> void:
	kingdom_card_flipped.emit(active_kingdom, flipped_card)

func get_wins_required(kingdom: CardData) -> int:
	var i = 1
	for card_holder in get_children():
		if kingdom.equals(card_holder.get_child(0).data):
			return i
		i += 1
	return -1 # should never be reached


func _on_emissary_game_player_spade_advisor_used(prev: CardData, next: CardData) -> void:
	for card_holder in get_children():
		var kingdom = card_holder.get_child(0) as Card
		if prev.equals(kingdom.data):
			kingdom.set_card_data(next)
		elif next.equals(kingdom.data):
			kingdom.set_card_data(prev)


func _on_emissary_game_player_kingdom_won(kingdom: CardData) -> void:
	for card_holder in get_children():
		var card = card_holder.get_child(0) as Card
		if kingdom.equals(card.data):
			card.reset_texture_and_data()
			(card_holder as CardHighlighter)._unhighlight()
			print(card.get_child(0).name + " has been queue_freed")
			for stacked_card in card.get_children():
				stacked_card.queue_free()
