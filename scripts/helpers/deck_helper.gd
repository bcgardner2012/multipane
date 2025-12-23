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
