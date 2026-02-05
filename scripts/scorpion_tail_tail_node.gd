extends Control
class_name ScorpionTailTailNode

func update(tail: Array[CardData]) -> void:
	var i = 0
	for card in tail:
		var child = get_child(i) as Card
		child.set_card_data(card)
		child.visible = true
		i += 1
	for j in range(i, get_child_count()):
		var child = get_child(j) as Card
		child.reset_texture_and_data()
		child.visible = false
