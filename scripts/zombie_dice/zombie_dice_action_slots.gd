extends VBoxContainer
class_name ZombieDiceActionSlots

func populate(cards: Array[CardData]) -> void:
	if cards == null or cards.size() < 3:
		print("Error: too few cards passed to populate")
		return
	
	# TODO: skip if action is flee
	$Card.set_card_data(cards[0])
	$Card2.set_card_data(cards[1])
	$Card3.set_card_data(cards[2])
