extends VBoxContainer
class_name ZombieDiceHumanSlots

@export var action_slots: ZombieDiceActionSlots

# overwrite card slots with these. Skip those whose action is Flee.
func populate(cards: Array[CardData]) -> void:
	var j = 0
	for i in range(0, 3):
		if not _action_is_flee(i) and j < cards.size():
			get_child(i).set_card_data(cards[j])
			j += 1

func _action_is_flee(index: int) -> bool:
	var card_node = action_slots.get_child(index) as Card
	return card_node != null and card_node.data != null and card_node.data.suit == CardData.Suit.SPADES
