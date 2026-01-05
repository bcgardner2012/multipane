extends Control
class_name BardsAndNoblesStoreArea

var card_holders: Array[CardHighlighter]

func _ready() -> void:
	card_holders = []
	card_holders.append_array($TopShelf.get_children())
	card_holders.append_array($BottomShelf.get_children())

# return true if we successfully populated shelf
func populate(card: CardData) -> bool:
	var card_holder = _get_next_empty_card_holder()
	if card_holder != null:
		var card_node = card_holder.get_child(0)
		card_node.set_card_data(card)
		card_holder._unhighlight()
		return true
	return false

func _get_next_empty_card_holder() -> CardHighlighter:
	for card_holder in card_holders:
		if card_holder.get_child(0).data == null:
			return card_holder
	return null

func discard(cards: Array[CardData]) -> void:
	for card_holder in card_holders:
		var card_node = card_holder.get_child(0) as Card
		if card_node.data in cards:
			card_node.reset_texture_and_data()
			card_holder._unhighlight()
