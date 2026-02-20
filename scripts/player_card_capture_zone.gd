extends Control
class_name PlayerCardCaptureZone

const RIGHTMOST = 3

var _enqueued_unh_: CardData

# inconsistencies exist when updating the same value multiple times
# in response to some signal in various places. Wait until next frame.
func _process(_delta: float) -> void:
	if _enqueued_unh_ != null:
		_unhighlight(_enqueued_unh_)
		_enqueued_unh_ = null

func populate(hand: Array[CardData]) -> void:
	for i in range(0, RIGHTMOST + 1):
		var next_card_h = get_child(i) as CardHighlighter
		var next_card = next_card_h.get_child(0) as Card
		if i < hand.size():
			next_card.set_card_data(hand[i])
		else:
			next_card.reset_texture_and_data()
		next_card_h._unhighlight()

func enqueue_unhighlight(data: CardData) -> void:
	_enqueued_unh_ = data

func _unhighlight(data: CardData) -> void:
	for child in get_children():
		var highlighter = child as CardHighlighter
		var card = highlighter.get_child(0) as Card
		if data.equals(card.data):
			highlighter._unhighlight()
			return

func remove(selected_cards: Array[CardData]) -> void:
	for i in range(0, RIGHTMOST + 1):
		var card_highlighter = get_child(i) as CardHighlighter
		var card_node = card_highlighter.get_child(0)
		for selected_card in selected_cards:
			if selected_card.equals(card_node.data):
				card_node.reset_texture_and_data()
				card_highlighter._unhighlight()
