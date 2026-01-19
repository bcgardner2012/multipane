extends VBoxContainer
class_name JokerJailbreakSlots

var card_nodes: Array[CardHighlighter]

func _ready() -> void:
	card_nodes = []
	card_nodes.append_array($TopRow.get_children())
	card_nodes.append_array($MidRow.get_children())
	card_nodes.append_array($BottomRow.get_children())
	

# iterate left to right, top to bottom, and assign CardDatas to each slot
# always expects a 9-element array, with nulls where stacks are empty
func populate(cards: Array[CardData]) -> void:
	for i in range(cards.size()):
		card_nodes[i]._unhighlight()
		var card_node = card_nodes[i].get_child(0) as Card
		if cards[i] != null:
			card_node.set_card_data(cards[i])
		else:
			card_node.reset_texture_and_data()
