extends HBoxContainer
class_name SSGoonRow

func show_goons(goons: Array[CardData]) -> void:
	var visible_child_count = mini(goons.size() * 2 -1, 11)
	for i in range(0, visible_child_count):
		var c = get_child(i)
		c.visible = true
		if i % 2 == 0: # is even
			var goon_card = c as Card
			# i will be twice the index in goons array for corresponding card node
			goon_card.set_card_data(goons[i/2])
	
	# hide those not used yet
	for i in range(visible_child_count, get_child_count()):
		get_child(i).visible = false

func get_goon_index(goon: CardData) -> int:
	for i in range(0, get_child_count(), 2):
		var c = get_child(i) as Card
		if goon.equals(c.data):
			return i
	return -1 # may happen when clicking on a defeated goon after clearing it

# do we really need to clear the data? Let's just hide the cards.
func clear_goons() -> void:
	for c in get_children():
		c.visible = false
