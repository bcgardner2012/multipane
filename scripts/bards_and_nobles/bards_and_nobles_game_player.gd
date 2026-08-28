extends Node
class_name BardsAndNoblesGamePlayer

# errors
signal no_cards_selected_error()
signal wrong_value_error()

@export var store_deck_label: Label
@export var customer_deck_label: Label
@export var trade_in_deck_label: Label
@export var guild_standing_label: Label

@export var store_area: BardsAndNoblesStoreArea
@export var customer_card_node: Card
@export var trade_in_card_node: Card

@export var _signals: BardsAndNoblesGamePane

var store_deck: Array[CardData]
var customer_deck: Array[CardData]
var trade_in_deck: Array[CardData]

var guild_standing: int

var offer: Array[CardData]

func _ready() -> void:
	offer = []
	
	store_deck = []
	store_deck.append_array($CardDatas.get_children())
	DeckHelper.shuffle(store_deck)
	
	trade_in_deck = []
	for i in range(0, 12):
		trade_in_deck.append(store_deck.pop_front())
	
	customer_deck = []
	customer_deck.append_array($CustomerCards.get_children())
	DeckHelper.shuffle(customer_deck)

func _on_deck_start_game() -> void:
	for i in range(0, 8):
		var drawn_card = store_deck.pop_front()
		store_area.populate(drawn_card)
	store_deck_label.text = str(store_deck.size())
	
	_setup_customer_area()
	_signals.game_started.emit(customer_card_node.data, trade_in_card_node.data)

# add to an offer and compare value to customer sum
func _on_card_use_card(data: CardData, button_index: int) -> void:
	if offer == null:
		offer = []
	
	if button_index == MOUSE_BUTTON_LEFT and data != null:
		if not data in offer:
			offer.append(data)
	elif button_index == MOUSE_BUTTON_RIGHT and data != null:
		DeckHelper.remove_card(offer, data)


func _on_offer_button_pressed() -> void:
	# validate offer
	if not _validate_offer():
		return
	
	# increment standing if applicable
	var guild_standing_delta = 0
	for card in offer:
		if card.same_suit(customer_card_node.data):
			guild_standing_delta += 1
	guild_standing += guild_standing_delta
	guild_standing_label.text = "Standing: " + str(guild_standing)
	
	# discard offer cards
	store_area.discard(offer)
	var draw_count = offer.size()
	offer = []
	
	# draw new cards
	for i in range(0, draw_count):
		var drawn_card = store_deck.pop_front()
		if drawn_card != null:
			store_area.populate(drawn_card)
	store_deck_label.text = str(store_deck.size())
	
	# put trade-in on deck bottom
	if not store_area.populate(trade_in_card_node.data):
		store_deck.push_back(trade_in_card_node.data)
		store_deck_label.text = str(store_deck.size())
	
	_signals.sale_made.emit(customer_card_node.data, trade_in_card_node.data, guild_standing_delta, customer_deck[0])
	if not _setup_customer_area():
		_signals.game_over.emit(guild_standing)


func _on_turn_away_button_pressed() -> void:
	_signals.customer_turned_away.emit(customer_card_node.data, customer_deck[0])
	var standing_delta = customer_card_node.data.rank - 10
	guild_standing -= standing_delta
	guild_standing_label.text = "Standing: " + str(guild_standing)
	if not _setup_customer_area() or guild_standing < 0:
		_signals.game_over.emit(guild_standing)

func _get_customer_sum() -> int:
	return customer_card_node.data.rank + trade_in_card_node.data.rank

func _get_offer_values() -> Array[int]:
	var values: Array[int] = []
	var value = 0
	var ace_count = 0
	for card in offer:
		# same suit as trade-in means you can only give it away freely
		if not card.same_suit(trade_in_card_node.data):
			value += card.rank
			if card.rank == 11: # is an Ace
				ace_count += 1
	values.append(value)
	
	if ace_count > 0:
		for i in range(0, ace_count):
			value -= 10
			values.append(value)
			# the offer has a number of potential values equal to number of aces + 1
	return values

# return true if valid
func _validate_offer() -> bool:
	if offer == null or offer.size() == 0:
		no_cards_selected_error.emit()
		return false
	if not _get_customer_sum() in _get_offer_values():
		wrong_value_error.emit()
		return false
	return true

# return false if customer area could not be setup (empty decks)
func _setup_customer_area() -> bool:
	if customer_deck.size() <= 0 or trade_in_deck.size() <= 0:
		return false
	
	var customer = customer_deck.pop_front()
	customer_card_node.set_card_data(customer)
	customer_deck_label.text = str(customer_deck.size())
	
	var tradeIn = trade_in_deck.pop_front()
	trade_in_card_node.set_card_data(tradeIn)
	trade_in_deck_label.text = str(trade_in_deck.size())
	return true
