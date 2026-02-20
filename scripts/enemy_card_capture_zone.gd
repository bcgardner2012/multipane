extends Control
class_name EnemyCardCaptureZone

const RIGHTMOST = 3

# populate children. If too few cards in hand, move right.
func populate(hand: Array[CardData]) -> void:
	for i in range(0, RIGHTMOST + 1):
		var next_card = get_child(RIGHTMOST - i) as Card
		var hand_index = hand.size() - 1 - i
		if hand_index >= 0 and hand[hand_index] != null:
			next_card.set_card_data(hand[hand_index])
		else:
			next_card.reset_texture_and_data()

# slide cards to the right to fill gaps
func remove(card: CardData) -> void:
	#var gap_index = -1
	for i in range(0, RIGHTMOST + 1):
		var card_node = get_child(i) as Card
		if card.equals(card_node.data):
			card_node.reset_texture_and_data()
			#gap_index = i
			break
	# populate does this implicitly...
	#_slide_right(gap_index)

func _slide_right(gap_index: int) -> void:
	for i in range(0, gap_index):
		var left_of_gap = get_child(gap_index - i - 1) as Card
		var gap = get_child(gap_index - i) as Card
		gap.set_card_data(left_of_gap.data)
		left_of_gap.reset_texture_and_data()
		# the gap has now move one space left (hence, -i)
