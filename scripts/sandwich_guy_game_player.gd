extends Node
class_name SandwichGuyGamePlayer

signal too_many_cards()
signal too_few_cards()
signal not_equidistant_ranks()

# quality can be 0-2: different colors, same color, same suit
signal sandwich_served(sandwich: Array[CardData], quality: int)
signal game_won()

@export var hand_node: Control
@export var deck_label: Label

var deck: Array[CardData]
var hand: Array[CardData]
var sandwich: Array[CardData]

func _ready() -> void:
	deck = []
	for card in $CardDatas.get_children():
		deck.append(card)
	DeckHelper.shuffle(deck)

func _on_deck_start_game() -> void:
	hand = []
	# draw 8 cards, populate hand
	for card_holder in hand_node.get_children():
		var drawn_card = deck.pop_front()
		hand.append(drawn_card)
		var card_node = card_holder.get_child(0) as Card
		card_node.set_card_data(drawn_card)
	
	deck_label.text = str(deck.size())


func _on_card_use_card(data: CardData, button_index: int) -> void:
	if sandwich == null:
		sandwich = []
	
	if button_index == MOUSE_BUTTON_LEFT:
		# add to sandwich
		sandwich.append(data)
	elif button_index == MOUSE_BUTTON_RIGHT:
		for i in range(0, sandwich.size()):
			var ingredient = sandwich[i]
			if ingredient.equals(data):
				sandwich.remove_at(i)
				break


func _on_serve_button_pressed() -> void:
	# validate sandwich
	if not _is_valid_sandwich():
		return
	
	# discard sandwich
	var quality = _get_sandwich_quality()
	sandwich_served.emit(sandwich, quality)
	var draw_count = quality + 2
	sandwich = []
	
	# draw X cards
	for card_holder in hand_node.get_children():
		var card_node = card_holder.get_child(0) as Card
		if card_node.data == null and deck.size() > 0 and draw_count > 0:
			card_node.set_card_data(deck.pop_front())
			draw_count -= 1
	
	deck_label.text = str(deck.size())
	if deck.size() <= 0:
		game_won.emit()

func _is_valid_sandwich() -> bool:
	if sandwich.size() < 3:
		too_few_cards.emit()
		return false
	elif sandwich.size() > 3:
		too_many_cards.emit()
		return false
	
	sandwich = DeckHelper.sort_by_rank(sandwich)
	var d1 = sandwich[1].rank - sandwich[0].rank
	var d2 = sandwich[2].rank - sandwich[1].rank
	var d3 = (sandwich[0].rank + 13) - sandwich[2].rank # detects wrapping
	
	var are_two_ds_equal = d1 == d2 or d2 == d3 or d1 == d3
	if not are_two_ds_equal:
		not_equidistant_ranks.emit()
		return false
	
	return true

func _get_sandwich_quality() -> int:
	if sandwich[0].same_suit(sandwich[1]) and sandwich[0].same_suit(sandwich[2]) and sandwich[1].same_suit(sandwich[2]):
		return 2
	elif sandwich[0].same_color(sandwich[1]) and sandwich[0].same_color(sandwich[2]) and sandwich[1].same_color(sandwich[2]):
		return 1
	return 0
