extends Node
class_name ScoundrelBrain

# This brain is now capable of winning, but seems to make some clear mistakes
# Notably, when using any weapon with say 6 dur, it will barehand a 5 monster, then
# use the weapon on a 4 monster, both in the same room. It should weapon on both.
# This is a result of taking it one card at a time and barehanding based on health %.

# delay before making another decision, so we can watch
const DELAY = 1.5
var timer: float

var is_active: bool
var signals: ScoundrelBrainSignals
var game_player: ScoundrelGamePlayer

##### Turn Data #####
# AI can skip a card when processing left-to-right. After MAX, just resolve in order.
const MAX_SKIPS = 8
var skips: int
var is_skipping_frames: bool # if we did a skip last frame, don't do a DELAY

# Needs to be separate from the game_player's state
var cards_resolved: int
var sorted_cards: Array[CardData] 
var card_index: int # the index of the card I am currently thinking about
##### Turn Data #####

# signals will be undefined when this is first called
func activate() -> void:
	is_active = true
	signals = get_parent()
	game_player = signals.get_parent()
	sorted_cards = []
	signals.start_game.emit()

func deactivate() -> void:
	is_active = false

# decision making loop, slow it down so we can watch
func _process(delta: float) -> void:
	if not is_active:
		return
	timer += delta
	if timer > DELAY or is_skipping_frames:
		timer = 0.0
		_do_turn()

func _do_turn() -> void:
	if _health() <= 0:
		# I died...
		deactivate()
		return
	
	# if cards_resolved is 0, we need to get and sort cards
	if cards_resolved == 0:
		var card_nodes = game_player.room.get_children()
		var cards: Array[CardData] = []
		for card_node in card_nodes:
			if card_node.data != null: # false in cases on last room
				cards.append(card_node.data)
			
		if cards.size() < 4:
			# we made it through the dungeon! We win!
			deactivate()
			return
		
		sorted_cards = _sort_cards(cards)
		if game_player.can_run and _should_run_away():
			_run_away()
			return
	
	# if cards_resolved is 3, reset to 0 and wait for the next frame
	if cards_resolved == 3:
		cards_resolved = 0
		card_index = 0
		sorted_cards = []
		return
	
	var card = sorted_cards[card_index]
	
	# if skips exceed max, just resolve the first card
	if skips >= MAX_SKIPS:
		# skips will become exhausted because we have no clear good choices.
		# ideally, we would choose the least bad then... which means:
		# smashing weaker potions over stronger >
		# equipping weaker weapons over fighting > 
		# fighting weaker monsters first
		# basically, re-sort by suit, then in reverse order by rank
		# re-sorting multiple times shouldn't be a huge deal, this will occur close to
		# end of run and with fewer cards
		sorted_cards = _desperate_sort_cards(sorted_cards)
		card_index = 0
		
		# take 1 desperate action, then go back to normal logic until we hit the limit again
		_play(sorted_cards[card_index])
		sorted_cards = _sort_cards(sorted_cards)
		skips = 0
		return
	
	# if hearts and rank >= dmg taken - some threshold, play. Else skip.
	if card.suit == CardData.Suit.HEARTS:
		if game_player.can_heal and _is_heal_tolerable(card):
			_play(card)
			return
		else:
			_skip()
			return
	
	if card.suit == CardData.Suit.DIAMONDS:
		# if unarmed, equip
		if game_player.equipped_weapon == null or game_player.durability <= 2:
			# null means no weapon found yet, 2 dur means weapon is broken
			_play(card)
			return
		elif _is_weapon_swap_tolerable(card): 
			_play(card)
			return
		else:
			_skip()
			return
	
	# at this point, card must be black
	if _is_unarmed_dmg_tolerable(card):
		# do unarmed attack
		_play(card, MOUSE_BUTTON_RIGHT)
		return
	elif _is_armed_dmg_tolerable(card):
		# do armed attack
		_play(card)
		return
	else:
		# I'm going to take too much damage. Skip for now.
		_skip()
		return

func _is_heal_tolerable(card: CardData) -> bool:
	var dmg = 20 - _health()
	if dmg >= card.rank - 0: # means we will waste at most 1 HP from a potion. TODO: config this
		return true
	return false

func _is_weapon_swap_tolerable(card: CardData) -> bool:
	# TODO: extend this class and implement a Hook function
	# if my weapon's durability is less than 7, that means it can be used on less
	# than half of the monsters I will encounter. So swap it.
	return game_player.equipped_weapon == null or (game_player.durability < 7 and not _weapon_is_immediately_useful())

func _weapon_is_immediately_useful() -> bool:
	for card in sorted_cards:
		if card.suit == CardData.Suit.CLUBS or card.suit == CardData.Suit.SPADES:
			if game_player.equipped_weapon.rank >= card.rank and game_player.durability > card.rank:
				return true
	return false

func _is_unarmed_dmg_tolerable(card: CardData) -> bool:
	# TODO: hook function
	# if it would take more than 50% of my current health, false
	return card.rank < 0.5 * _health()

func _is_armed_dmg_tolerable(card: CardData) -> bool:
	# TODO: hook function
	# if durability < card.rank, we can't use the weapon, it'll still be unarmed
	if game_player.durability <= card.rank:
		return card.rank < _health()
	else:
		return card.rank - game_player.equipped_weapon.rank < _health()

func _should_run_away() -> bool:
	if _is_premature_red_flush():
		return true
	
	var potential_dmg = 0
	var virtual_durability = game_player.durability
	var virtual_can_heal = true
	var virtual_weapon_rank = 0
	
	if game_player.equipped_weapon != null:
		virtual_weapon_rank = game_player.equipped_weapon.rank
	
	var index = 0
	for card in sorted_cards:
		if index == sorted_cards.size() - 1:
			# when sorted, 4th card is a monster. We don't have to fight it
			# and can run upon clearing the other 3 cards.
			break
		
		# with other cards factored in, I can now consider worst case scenario vs
		# these monsters.
		if card.suit == CardData.Suit.CLUBS or card.suit == CardData.Suit.SPADES:
			if virtual_durability > card.rank:
				potential_dmg += card.rank - virtual_weapon_rank
				virtual_durability = card.rank
			else:
				potential_dmg += card.rank
				
		# HEARTS are considered first and health will be replenished as needed
		if card.suit == CardData.Suit.HEARTS and virtual_can_heal:
			potential_dmg -= card.rank
			virtual_can_heal = false
		# DIAMONDS are considered second and if I'm willing to swap, that will influence
		# future damage potential. Factor that in.
		if card.suit == CardData.Suit.DIAMONDS and _is_weapon_swap_tolerable(card):
			virtual_weapon_rank = card.rank
			virtual_durability = 15
		
		index += 1
	
	return potential_dmg >= _health()

func _is_premature_red_flush() -> bool:
	if _is_red_flush() and _health() > 10 and game_player.equipped_weapon != null and game_player.durability > 12:
		return true
	return false

func _is_red_flush() -> bool:
	var red_flush = true
	for card in sorted_cards:
		if card.suit == CardData.Suit.CLUBS or card.suit == CardData.Suit.SPADES:
			red_flush = false
			break
	return red_flush

# sorts by suit first H,D,SC, then by rank (ex, H10, D11, D9, S3)
# greater first
func _sort_cards(cards: Array[CardData]) -> Array[CardData]:
	var hearts = _sort_extract_by_suit([CardData.Suit.HEARTS], cards)
	var diamonds = _sort_extract_by_suit([CardData.Suit.DIAMONDS], cards, false)
	var blacks = _sort_extract_by_suit([CardData.Suit.SPADES, CardData.Suit.CLUBS], cards)
	
	var sorted: Array[CardData] = []
	sorted.append_array(hearts)
	sorted.append_array(diamonds)
	sorted.append_array(blacks)
	return sorted

func _desperate_sort_cards(cards: Array[CardData]) -> Array[CardData]:
	var hearts = _sort_extract_by_suit([CardData.Suit.HEARTS], cards, false)
	var diamonds = _sort_extract_by_suit([CardData.Suit.DIAMONDS], cards, false)
	var blacks = _sort_extract_by_suit([CardData.Suit.SPADES, CardData.Suit.CLUBS], cards, false)
	
	var sorted: Array[CardData] = []
	sorted.append_array(diamonds)
	sorted.append_array(hearts)
	sorted.append_array(blacks)
	return sorted

func _sort_extract_by_suit(suits: Array[CardData.Suit], cards: Array[CardData], descending: bool = true) -> Array[CardData]:
	var suited_cards: Array[CardData] = []
	for card in cards:
		if card.suit in suits:
			if suited_cards.size() == 0:
				suited_cards.append(card)
			else:
				for i in range(0, suited_cards.size()):
					var h = suited_cards[i]
					if (descending and h.rank < card.rank) or (not descending and h.rank > card.rank):
						suited_cards.insert(i, card)
						break
					elif i == suited_cards.size() - 1:
						suited_cards.append(card)
						break
	return suited_cards

func _skip() -> void:
	skips += 1
	card_index += 1
	card_index %= sorted_cards.size()
	is_skipping_frames = true

func _play(card: CardData, button: int = MOUSE_BUTTON_LEFT) -> void:
	is_skipping_frames = false
	signals.play_card.emit(card, button)
	cards_resolved += 1
	if cards_resolved == 3:
		cards_resolved = 0
		card_index = 0
		sorted_cards = []
	else:
		sorted_cards.remove_at(card_index)
		card_index = 0

func _health() -> int:
	return game_player.health_slider.currentValue

func _run_away() -> void:
	signals.run_away.emit()
	card_index = 0
	cards_resolved = 0
	sorted_cards = []
