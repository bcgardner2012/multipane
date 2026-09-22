extends Node
class_name BetrothalGamePlayer

@export var play_area: BetrothalPlayArea
@export var deck_count_label: Label

var deck: Array[CardData]

var cards_in_play: Array[CardData]
var selected_cards: Array[CardData]

var _signals: BetrothalGamePane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck = []
	for child in $CardDatas.get_children():
		var card = child as CardData
		deck.append(card)
	DeckHelper.shuffle(deck)
	
	var king_hearts = $"QH&KH/HK" as CardData
	deck.append(king_hearts)
	var queen_hearts = $"QH&KH/HQ" as CardData
	deck.insert(0, queen_hearts)
	
	_signals = get_parent()


func _on_deck_start_game() -> void:
	_on_deck_deck_clicked()


func _on_deck_deck_clicked() -> void:
	var card = _safe_pop()
	if card == null:
		return
	
	# false if card failed to add, return to deck
	if not play_area.add_card(card):
		deck.insert(0, card)
		return
	
	cards_in_play.append(card)
	_signals.card_drawn.emit(card)

func _safe_pop():
	if deck.size() > 0:
		deck_count_label.text = str(deck.size()-1)
		return deck.pop_front()
	deck_count_label.text = "0"
	return null


func _on_card_use_card(data: CardData, button_index: int) -> void:
	if button_index == MOUSE_BUTTON_RIGHT:
		selected_cards.remove_at(selected_cards.find(data))
		return
	
	if not data in selected_cards:
		selected_cards.append(data)
		if selected_cards.size() == 2:
			# check if valid pairing
			if not (selected_cards[0].same_suit(selected_cards[1]) or selected_cards[0].rank == selected_cards[1].rank):
				return
			
			# check if distance is correct
			var indexes = play_area.get_indexes(selected_cards)
			var dist = abs(indexes[1] - indexes[0])
			if dist < 2 or dist > 3:
				return
			
			# remove cards and cleanup
			var removed = play_area.remove_between(selected_cards)
			_signals.cards_removed.emit(removed.size())
			DeckHelper.remove_cards(cards_in_play, removed)
			selected_cards = []
			play_area.cleanup(cards_in_play)
			
			if cards_in_play.size() == 2 and cards_in_play[1].rank == 13 and cards_in_play[1].suit == CardData.Suit.HEARTS:
				_signals.game_won.emit()
				pass
	
