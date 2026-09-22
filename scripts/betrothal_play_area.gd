extends Control
class_name BetrothalPlayArea

const MAX_IN_ROW = 16

var should_cleanup: bool
var cached_cards: Array[CardData]

func _process(_delta: float) -> void:
	if should_cleanup:
		should_cleanup = false
		_cleanup()

func _cleanup() -> void:
	_unhighlight($Row1)
	_unhighlight($Row2)
	for i in range(cached_cards.size()):
		var c = null
		if i < MAX_IN_ROW:
			c = $Row1.get_child(i).get_child(0) as Card
		else:
			c = $Row2.get_child(i - MAX_IN_ROW).get_child(0) as Card
		c.set_card_data(cached_cards[i])
		c.get_parent().visible = true

func _unhighlight(row: Control) -> void:
	for child in row.get_children():
		var ch = child as CardHighlighter
		ch.reset_and_hide()
		(ch.get_child(0) as Card).reset_texture_and_data()

func cleanup(cards_in_play: Array[CardData]) -> void:
	should_cleanup = true
	cached_cards = cards_in_play

# returns the cards removed
func remove_between(cards: Array[CardData]) -> Array[CardData]:
	var ret: Array[CardData] = []
	var arr = get_indexes(cards)
	arr.sort()
	for i in range(arr[1] - 1, arr[0], -1): # remove highest pos to lowest
		# get by index/IntSticker
		if i >= MAX_IN_ROW:
			ret.append(_reset_card_holder($Row2, i - MAX_IN_ROW))
		else:
			ret.append(_reset_card_holder($Row1, i))
	return ret
	
	# the earliest index+1 needs to be set to the later card selected (move left)
	#var c = null
	#if arr[0] >= MAX_IN_ROW:
	#	var i = arr[0] - MAX_IN_ROW + 1
	#	c = $Row2.get_child(i).get_child(0) as Card
	#else:
	#	var i = arr[0] + 1
	#	if i == 16: # edge case, last card in first row was first selected
	#		c = $Row2.get_child(0).get_child(0) as Card
	#	else:
	#		c = $Row1.get_child(i).get_child(0) as Card
	#c.set_card_data(cards[1])
	#c.get_parent().visible = true

func get_indexes(cards: Array[CardData]) -> Array[int]:
	var arr: Array[int] = []
	for card in cards:
		arr.append(_find_card(card))
	return arr

# return false if could not add due to exceeding 32 cards
func add_card(card: CardData) -> bool:
	if not _set_next_child($Row1, card):
		return _set_next_child($Row2, card)
	return true

func _set_next_child(row: Control, card: CardData) -> bool:
	for child in row.get_children():
		var ch = child as CardHighlighter
		if not ch.visible:
			var chc = ch.get_child(0) as Card
			chc.set_card_data(card)
			ch.visible = true
			return true
	return false

func _find_card(card: CardData) -> int:
	var i = _find_card_in_row(card, $Row1)
	if i == -1:
		return _find_card_in_row(card, $Row2)
	return i

# return -1 if not found
func _find_card_in_row(card: CardData, row: Control) -> int:
	for child in row.get_children():
		var ch = child as CardHighlighter
		if not ch.visible: # reached invisible elements, not found
			return -1
		var chc = ch.get_child(0) as Card
		if chc.data.equals(card):
			return ch.get_child(1).value
	return -1

# returns card reset
func _reset_card_holder(row: Control, i: int) -> CardData:
	var ch = row.get_child(i) as CardHighlighter
	ch.reset_and_hide()
	var c = ch.get_child(0) as Card
	var data = c.data
	c.reset_texture_and_data()
	return data
