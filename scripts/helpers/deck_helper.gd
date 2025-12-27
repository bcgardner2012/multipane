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
