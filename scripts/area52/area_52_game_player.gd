extends Node
class_name Area52GamePlayer

signal too_many_humans_played()
signal too_few_humans_played()
signal invalid_sum_played()
signal invalid_color_played()
signal too_low_single_rank_played()
signal invalid_sacrifice_played()

signal dual_attack_performed(humans: Array[CardData], alien: CardData, wave: int)
signal single_attack_performed(human: CardData, alien: CardData)
signal sacrifice_performed(human: CardData, alien: CardData, replacement: CardData)

signal trigger_highlight(card: CardData)
signal game_over()
signal game_won()
signal new_wave_incoming()
signal defender_drawn(deck_size: int)
signal aliens_drawn(aliens: Array[CardData])

@export var alien_card_nodes: Array[Card]
var aliens_in_play: Array[CardData]

@export var human_card_nodes: Array[Card]

@export var alien_deck_label: Label
@export var human_deck_label: Label
@export var wave_label: Label

var alien_deck: Array[CardData]
var human_deck: Array[CardData]
var discard_deck: Array[CardData]

var selected_humans: Array[CardData]
var targeted_alien: CardData

var wave: int

func _ready() -> void:
	alien_deck = []
	human_deck = []
	discard_deck = []
	for card in $CardDatas.get_children():
		if card.suit == CardData.Suit.HEARTS or card.suit == CardData.Suit.DIAMONDS:
			alien_deck.append(card)
		else:
			human_deck.append(card)
	DeckHelper.shuffle(alien_deck)
	DeckHelper.shuffle(human_deck)

func _on_human_card_use_card(data: CardData, button_index: int) -> void:
	if selected_humans == null:
		selected_humans = []
	
	if button_index == MOUSE_BUTTON_LEFT:
		var already_added = false
		for human in selected_humans:
			if human.equals(data):
				already_added = true
				break
		
		if not already_added:
			selected_humans.append(data)
	elif button_index == MOUSE_BUTTON_RIGHT:
		var i = 0
		for human in selected_humans:
			if human.equals(data):
				selected_humans.remove_at(i)
				break
			i += 1

# only valid if the selected one or two humans and proper conditions met
# sacrifice is not handled here
func _on_alien_card_use_card(data: CardData, button_index: int) -> void:
	if button_index == MOUSE_BUTTON_LEFT and data.equals(targeted_alien):
		if _move_is_valid(): # also triggers warning messages if not valid
			if _move_is_dual_attack():
				dual_attack_performed.emit(selected_humans, targeted_alien, wave)
				discard_deck.append(targeted_alien)
				if wave > 0:
					for h in selected_humans:
						if h.same_color(targeted_alien):
							discard_deck.append(h)
					_replace_dead_humans()
					# if human deck is empty and no more humans in play, game over
					if _check_loss_condition():
						game_over.emit()
			elif _move_is_single_attack():
				single_attack_performed.emit(selected_humans[0], targeted_alien)
				discard_deck.append(selected_humans[0])
			else:
				print("Move validation is not working right")
			
			selected_humans = []
			_cycle_target()
			if wave > 1:
				game_won.emit()

func _move_is_dual_attack() -> bool:
	return selected_humans.size() == 2

func _move_is_single_attack() -> bool:
	return selected_humans.size() == 1

func _move_is_valid() -> bool:
	return not _too_few_humans() and not _too_many_humans() and not _wrong_color() and not _wrong_sum()

func _too_many_humans() -> bool:
	if selected_humans.size() > 2:
		too_many_humans_played.emit()
		return true
	return false

func _too_few_humans() -> bool:
	if selected_humans == null or selected_humans.size() <= 0:
		too_few_humans_played.emit()
		return true
	return false

func _wrong_color() -> bool:
	if selected_humans.size() == 1 and selected_humans[0].is_red() == targeted_alien.is_red():
		invalid_color_played.emit()
		return true
	return false

func _wrong_sum() -> bool:
	if selected_humans.size() == 1 and selected_humans[0].rank <= targeted_alien.rank:
		too_low_single_rank_played.emit()
		return true
	if selected_humans.size() == 2:
		var sum = selected_humans[0].rank + selected_humans[1].rank
		if sum != targeted_alien.rank:
			invalid_sum_played.emit()
			return true
	return false


func _on_deck_start_game() -> void:
	# pop the first 3 cards from alien deck, load into slots
	_draw_aliens()
	
	# pop the first 6 cards from human deck, load into slots
	for i in range(0, human_card_nodes.size()):
		var h = human_deck.pop_front()
		human_card_nodes[i].set_card_data(h)
	human_deck_label.text = str(human_deck.size())

func _draw_aliens() -> void:
	aliens_in_play = []
	for i in range(0, alien_card_nodes.size()):
		var a = alien_deck.pop_front()
		if a != null: # last round of wave 1 will only have 2 cards
			aliens_in_play.append(a)
			alien_card_nodes[i].set_card_data(a)
	targeted_alien = aliens_in_play[0]
	trigger_highlight.emit(targeted_alien)
	alien_deck_label.text = str(alien_deck.size())
	aliens_drawn.emit(aliens_in_play)


func _on_sacrifice_button_pressed() -> void:
	if selected_humans.size() != 1:
		invalid_sacrifice_played.emit()
		return
	
	sacrifice_performed.emit(selected_humans[0], targeted_alien, human_deck.pop_front())
	defender_drawn.emit(human_deck.size())
	human_deck_label.text = str(human_deck.size())
	discard_deck.append(selected_humans[0])
	selected_humans = []
	alien_deck.append(targeted_alien)
	alien_deck_label.text = str(alien_deck.size())
	_cycle_target()

func _cycle_target() -> void:
	aliens_in_play.pop_front()
	if aliens_in_play.size() > 0:
		targeted_alien = aliens_in_play[0]
		trigger_highlight.emit(targeted_alien)
	elif alien_deck.size() <= 0:
		_start_next_wave()
	else:
		# draw more aliens
		_draw_aliens()

func _start_next_wave() -> void:
	wave += 1
	new_wave_incoming.emit()
	wave_label.text = "Wave " + str(wave + 1)
	# if wave == 2, you've won 2 waves, that's the end.
	# turn the discard deck into the alien deck, shuffle the alien deck
	alien_deck = discard_deck
	discard_deck = []
	DeckHelper.shuffle(alien_deck)
	# draw more aliens
	_draw_aliens()

func _replace_dead_humans() -> void:
	var should_emit = false
	for node in human_card_nodes:
		if node.data == null and human_deck.size() > 0:
			node.set_card_data(human_deck.pop_front())
			human_deck_label.text = str(human_deck.size())
			should_emit = true
	
	if should_emit:
		defender_drawn.emit(human_deck.size())

func _check_loss_condition() -> bool:
	return human_deck.size() <= 0 and _get_humans_in_play().size() <= 0

func _get_humans_in_play() -> Array[CardData]:
	var arr: Array[CardData] = []
	for node in human_card_nodes:
		if node.data != null:
			arr.append(node.data)
	return arr
