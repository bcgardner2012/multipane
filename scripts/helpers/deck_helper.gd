extends Node
class_name DeckHelper

# Fisher-Yates Shuffle Algorithm
static func shuffle(deck: Array[CardData]):
	var i = deck.size()
	while i > 0:
		var r = randi() % i
		var tmp = deck[r]
		deck[r] = deck[i-1]
		deck[i-1] = tmp
		i -= 1

# deck is a ref to the deck to init, node is the card data holder
static func init_deck(deck: Array[CardData], node: Node, should_shuffle: bool) -> void:
	for child in node.get_children():
		var card = child as CardData
		deck.append(card)
	if should_shuffle:
		DeckHelper.shuffle(deck)

static func sort_by_rank(deck: Array[CardData], descending: bool = false) -> Array[CardData]:
	var sorted_deck: Array[CardData] = []
	for card in deck:
		if sorted_deck.size() == 0:
			sorted_deck.append(card)
		else:
			for i in range(0, sorted_deck.size()):
				var h = sorted_deck[i]
				if (descending and h.rank < card.rank) or (not descending and h.rank > card.rank):
					sorted_deck.insert(i, card)
					break
				elif i == sorted_deck.size() - 1:
					sorted_deck.append(card)
					break
	return sorted_deck

static func contains_suit(deck: Array[CardData], suit: CardData.Suit) -> bool:
	for card in deck:
		if card.suit == suit:
			return true
	return false

static func get_suit_counts(deck: Array[CardData]) -> Dictionary:
	var counts = {}
	for suit in CardData.Suit.keys():
		counts[suit] = 0
		for card in deck:
			if card.suit == CardData.Suit.get(suit):
				counts[suit] += 1 
	return counts

static func remove_card(deck: Array[CardData], card: CardData) -> void:
	for i in range(0, deck.size()):
		if deck[i].equals(card):
			deck.remove_at(i)
			break

static func remove_cards(deck: Array[CardData], to_remove: Array[CardData]) -> void:
	for to_r in to_remove:
		if to_r in deck:
			remove_card(deck, to_r)

static func multi_pop(deck: Array[CardData], count: int) -> Array[CardData]:
	var stack: Array[CardData] = []
	for i in range(count):
		stack.append(deck.pop_front())
	return stack

static func is_flush_of(suit: CardData.Suit, deck: Array[CardData]) -> bool:
	for card in deck:
		if card.suit != suit:
			return false
	return true

static func is_flush(deck: Array[CardData]) -> bool:
	if deck.size() <= 0:
		return false
	
	var suit = deck[0].suit
	for card in deck:
		if card.suit != suit:
			return false
	return true

static func is_red_flush(deck: Array[CardData]) -> bool:
	for card in deck:
		if card.is_black():
			return false
	return true

static func is_black_flush(deck: Array[CardData]) -> bool:
	for card in deck:
		if card.is_red():
			return false
	return true

static func is_same_rank(deck: Array[CardData]) -> bool:
	if deck.size() <= 0:
		return false
	
	var rank = deck[0].rank
	for card in deck:
		if card.rank != rank:
			return false
	return true
