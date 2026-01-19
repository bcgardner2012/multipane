extends Node
class_name JokerJailbreakGamePlayer

signal sums_invalid_error(red_sum: int, black_sum: int)
signal cell_full_error()
signal deck_empty_error()

signal selection_confirmed()
signal game_won()

var deck: Array[CardData]

# stacks
var tl_stack: Array[CardData]
var tc_stack: Array[CardData]
var tr_stack: Array[CardData]
var ml_stack: Array[CardData]
var mc_stack: Array[CardData] # middle-center, special behaviors
var mr_stack: Array[CardData]
var bl_stack: Array[CardData]
var bc_stack: Array[CardData]
var br_stack: Array[CardData]

var all_stacks: Array[Array] # to reduce 9 block conditionals to a short for-loop

# labels
@export var deck_count_label: Label
@export var tl_label: Label
@export var tc_label: Label
@export var tr_label: Label
@export var ml_label: Label
@export var mr_label: Label
@export var bl_label: Label
@export var bc_label: Label
@export var br_label: Label

@export var red_sum_label: Label
@export var black_sum_label: Label

@export var slots: JokerJailbreakSlots

# selected cards
var selected_cards: Array[CardData]
var red_sum: int
var black_sum: int

var _signals: JokerJailbreakGamePane

func _ready() -> void:
	deck = []
	deck.append_array($CardDatas.get_children())
	DeckHelper.shuffle(deck)
	
	# populate corners
	tl_stack = _multi_pop(4)
	tr_stack = _multi_pop(4)
	bl_stack = _multi_pop(4)
	br_stack = _multi_pop(4)
	
	# populate walls
	tc_stack = _multi_pop(7)
	mr_stack = _multi_pop(7)
	bc_stack = _multi_pop(7)
	ml_stack = _multi_pop(7)
	
	# populate joker's cell
	mc_stack = []
	
	all_stacks = []
	all_stacks.append(tl_stack)
	all_stacks.append(tc_stack)
	all_stacks.append(tr_stack)
	all_stacks.append(ml_stack)
	all_stacks.append(mc_stack)
	all_stacks.append(mr_stack)
	all_stacks.append(bl_stack)
	all_stacks.append(bc_stack)
	all_stacks.append(br_stack)
	
	selected_cards = []

func _multi_pop(count: int) -> Array[CardData]:
	var stack: Array[CardData] = []
	for i in range(count):
		stack.append(deck.pop_front())
	return stack


func _on_deck_start_game() -> void:
	_signals = get_parent()
	slots.populate(_get_walls())
	_update_labels()

func _get_walls() -> Array[CardData]:
	var walls: Array[CardData] = []
	for stack in all_stacks:
		walls.append(_get_wall(stack))
	return walls

func _get_wall(stack: Array[CardData]) -> CardData:
	if stack.size() > 0:
		return stack[0]
	return null

func _update_labels() -> void:
	deck_count_label.text = str(deck.size())
	tl_label.text = str(tl_stack.size())
	tc_label.text = str(tc_stack.size())
	tr_label.text = str(tr_stack.size())
	ml_label.text = str(ml_stack.size())
	mr_label.text = str(mr_stack.size())
	bl_label.text = str(bl_stack.size())
	bc_label.text = str(bc_stack.size())
	br_label.text = str(br_stack.size())

func _update_sum_labels() -> void:
	red_sum_label.text = str(red_sum)
	black_sum_label.text = str(black_sum)

# the mc card's signals are not hooked up, will not come here
func _on_card_use_card(data: CardData, button_index: int) -> void:
	if button_index == MOUSE_BUTTON_LEFT:
		if data != null and not data in selected_cards:
			selected_cards.append(data)
			if data.is_red():
				red_sum += data.rank
			else:
				black_sum += data.rank
			_update_sum_labels()
	elif button_index == MOUSE_BUTTON_RIGHT:
		DeckHelper.remove_card(selected_cards, data)
		if data != null:
			if data.is_red():
				red_sum -= data.rank
			else:
				black_sum -= data.rank
			_update_sum_labels()


func _on_confirm_button_pressed() -> void:
	if selected_cards.size() <= 0:
		return
	
	if red_sum == black_sum:
		# match selected cards against top of each stack
		# delete top of matched stacks
		for card in selected_cards:
			for stack in all_stacks:
				if card.equals(_get_wall(stack)):
					stack.pop_front()
					break
		
		# mc card is automatically and forcefully applied to sums, pop it
		mc_stack.pop_front()
		_round_cleanup()
		
		# game won check
		if _game_won():
			game_won.emit()
			_signals.game_won.emit()
		else:
			selection_confirmed.emit()
			_signals.chipped.emit(all_stacks)
	else:
		sums_invalid_error.emit(red_sum, black_sum)


func _on_deck_deck_clicked() -> void:
	if mc_stack.size() >= 3:
		cell_full_error.emit()
		return
	if deck.size() <= 0:
		deck_empty_error.emit()
		return
	
	# draw from deck and add to mc_stack
	mc_stack.push_front(deck.pop_front())
	_round_cleanup()

func _round_cleanup() -> void:
	slots.populate(_get_walls())
	
	# erase selected_cards and sums
	selected_cards = []
	red_sum = 0
	black_sum = 0
	
	_maintain_unresolved_mc_cards()
	
	# update labels
	_update_labels()
	_update_sum_labels()

# you can't click the mc card, so calls here are the only way for it to affect sums
func _maintain_unresolved_mc_cards() -> void:
	var mc = _get_wall(mc_stack)
	if mc != null:
		if mc.is_red():
			red_sum += mc.rank
		else:
			black_sum += mc.rank

func _game_won() -> bool:
	return tc_stack.size() == 0 or bc_stack.size() == 0 or ml_stack.size() == 0 or mr_stack.size() == 0
