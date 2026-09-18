extends HauntedHouseGameStrategy
class_name HauntedHouseDeluxeStrategy

@export var items_node: HauntedHouseItems

func handle_card(card: CardData) -> bool:
	if card.rank >= 3 and card.rank <= 9:
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
				_handle_respite()
			10:
				_handle_random_event()
			11:
				_handle_trap()
			12:
				show_text.emit(
					"You see a beautiful woman, there one moment, gone the next! Surprisingly, you feel more at ease.",
					Color.YELLOW
				)
				# positive values heal
				_change_health(2)
			13:
				if HauntedHouseGamePlayer.Item.HOLY_WATER in items_node.items:
					items_node.hide_item(HauntedHouseGamePlayer.Item.HOLY_WATER)
					show_text.emit(
						"Sensing a foul apparition, you throw your holy water to ground!",
						Color.WHITE
					)
				else:
					show_text.emit(
						"You start shivering right before an object seems to hurl itself at you! You think you heard someone screaming at you.",
						Color.RED
					)
					_change_health(-3)
	return health_gauge.currentValue <= 0

func _fight_minion(card: CardData) -> void:
	var r = randi() % 2
	if r == 1:
		if card.rank < 6 and HauntedHouseGamePlayer.Item.SPRAY in items_node.items:
			items_node.hide_item(HauntedHouseGamePlayer.Item.SPRAY)
			show_text.emit(
				"You sprayed a spider that strayed too close!",
				Color.WHITE
			)
		elif card.rank >= 6 and HauntedHouseGamePlayer.Item.CANDLE in items_node.items:
			items_node.hide_item(HauntedHouseGamePlayer.Item.CANDLE)
			show_text.emit(
				"You wave your lit candle at a rat, scaring it away!",
				Color.WHITE
			)
		else:
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

func _handle_trap() -> void:
	if HauntedHouseGamePlayer.Item.FLASHLIGHT in items_node.items:
		items_node.hide_item(HauntedHouseGamePlayer.Item.FLASHLIGHT)
		show_text.emit("You spot a trap waiting for you with your flashlight! Avoided.", Color.WHITE)
		return
	
	var r = randi() % 6
	match r:
		0:
			show_text.emit("You hear a creaking, and then the floor drops under you! Lose -1 LIFE.", Color.RED)
			_change_health(-1)
		1:
			show_text.emit("A green claw shoots out from a mirror, clawing you. Lose -2 LIFE.", Color.RED)
			_change_health(-2)
		2:
			show_text.emit("The suit of armor near the fireplace comes to life, attacking you! Lose -2  LIFE", Color.RED)
			_change_health(-2)
		3:
			show_text.emit("The creepy skeletons in dusty chairs stand up, rushing at you, clawing. Lose -3 LIFE.", Color.RED)
			_change_health(-3)
		4:
			show_text.emit("Puppets on the bookshelves hop down, growling and throwing books. Lose -1 LIFE.", Color.RED)
			_change_health(-1)
		5:
			show_text.emit("A dead end! You could have sworn that was a door before...", Color.WHITE)

func _handle_respite() -> void:
	var r = randi() % 2
	if r == 0:
		show_text.emit("You find an empty room. A welcome respite.", Color.WHITE)
		return
	
	r = randi() % 6
	match r:
		0:
			show_text.emit("A candle! This will let you scare off some rats", Color.BLUE)
			add_item.emit(HauntedHouseGamePlayer.Item.CANDLE)
		1:
			show_text.emit("A dusty can of bug spray! The next Spider card does nothing.", Color.BLUE)
			add_item.emit(HauntedHouseGamePlayer.Item.SPRAY)
		2:
			show_text.emit("Holy Water! The bane of wicked ghosts.", Color.BLUE)
			add_item.emit(HauntedHouseGamePlayer.Item.HOLY_WATER)
		3:
			show_text.emit("Flashlight, barely working. Good enough to negate one trap.", Color.BLUE)
			add_item.emit(HauntedHouseGamePlayer.Item.FLASHLIGHT)
		4:
			show_text.emit("Bandages! Restore 2 life.", Color.YELLOW)
			_change_health(2)
		5:
			show_text.emit("You find an empty room. Searching it, you find nothing...", Color.WHITE)

func _handle_random_event() -> void:
	var r = randi() % 6
	if r < 2:
		show_text.emit("You find an empty room. Searching it, you find nothing...", Color.WHITE)
		return
	match r:
		2:
			show_text.emit("You find a potion you feel compelled to drink. +3 LIFE", Color.YELLOW)
			_change_health(3)
		3:
			show_text.emit("A gargoyle flies into you, knocking you into a wall! -2 LIFE", Color.RED)
			_change_health(-2)
		4:
			show_text.emit("A bat frisks you! You notice some of your things are missing...", Color.PURPLE)
			items_node.hide_all()
		5:
			_handle_respite()
