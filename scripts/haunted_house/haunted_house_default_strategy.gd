extends HauntedHouseGameStrategy
class_name HauntedHouseDefaultStrategy

# return true on game over
func handle_card(card: CardData) -> bool:
	if card.rank >= 3 and card.rank <= 10:
		_fight_minion(card)
	else:
		match card.rank:
			-99: # Joker
				_change_health(-5)
				show_text.emit(
					"You barely escaped a horror beyond your comprehension!",
					Color.RED
				)
			1:
				aces_found += 1
				if aces_found == 4:
					show_text.emit(
						"You found the last survivor! Let's get out of here! You win!",
						Color.GREEN
					)
					return true
				else:
					show_text.emit("You found a survivor!", Color.GREEN)
			2:
				show_text.emit("You find an empty room. A welcome respite.", Color.WHITE)
			11:
				show_text.emit("You feel a sudden chilling pain! Was that a ghost?", Color.RED)
				_change_health(-2)
			12:
				show_text.emit(
					"You see a beautiful woman, there one moment, gone the next! Surprisingly, you feel more at ease.",
					Color.YELLOW
				)
				# positive values heal
				_change_health(2)
			13:
				show_text.emit(
					"You start shivering right before an object seems to hurl itself at you! You think you heard someone screaming at you.",
					Color.RED
				)
				_change_health(-3)
	return health_gauge.currentValue <= 0

# default rules are to roll 2 dice and see if they exceed rank
func _fight_minion(card: CardData) -> void:
	var r = (randi() % 11) + 2
	if r < card.rank:
		_change_health(-1)
		show_text.emit(
			"You can't see it, but something tiny bit you",
			Color.RED
		)
	else:
		if card.rank < 6:
			show_text.emit("You stomped a sizable spider!", Color.WHITE)
		else:
			show_text.emit("You kicked a rat away!", Color.WHITE)
