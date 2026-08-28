extends Node
class_name ShadowSolitaireGamePlayer

signal invalid_selection()
signal player_died()
signal player_won()
signal bomb_used()
signal new_round_started(boss: CardData, health: int)
signal attacked(target: CardData, action: CardData)
signal joker_drawn()

@export var play_area: Control
@export var boss_deck_count: Label
@export var boss_card: Card
@export var deck_count: Label
@export var goon_row: SSGoonRow
@export var health_row: SSHealthRow
@export var action_card: Card
@export var ap_label: Label
@export var health_slider: GaugeSlider

const JOKER_RANK = -1

var court_cards: Array[CardData] # do pop_fronts
var deck: Array[CardData]
var discard_pile: Array[CardData]

var bomb_is_on: bool
var bomb_was_used: bool
var action_points: int

var boss: CardData
var goons_health: Array[int]
var goons: Array[CardData]
var strongest_goon = null
var weakest_goon = null

var _signals: ShadowSolitaireGamePane

func _ready() -> void:
	discard_pile = []
	deck = []
	deck.append_array($PlayingCards.get_children())
	DeckHelper.shuffle(deck)
	
	court_cards = []
	court_cards.append_array($CourtCards.get_children())
	# not much point in shuffling since J, Q, K is a required order


func _on_texture_button_grapple_clicked(card1: CardData, card2: CardData) -> void:
	var sum = _sum_cards(card1, card2)
	var action_context_rank = _context_value(action_card.data, true)
	if action_context_rank >= sum and action_context_rank <= _action_upper_limit(sum):
		var i1 = goons.find(card1)
		var i2 = goons.find(card2)
		goons_health[i1] = 0
		goons_health[i2] = 0
		_decrement_ap_and_show_health()
	else:
		invalid_selection.emit()

func _sum_cards(card1: CardData, card2: CardData) -> int:
	return _context_value(card1) + _context_value(card2)

func _context_value(card: CardData, is_action: bool = false) -> int:
	if card.rank <= 1:
		if not is_action:
			return strongest_goon.rank
		else:
			return weakest_goon.rank
	return card.rank

func _on_bomb_button_bomb_toggled() -> void:
	bomb_is_on = not bomb_is_on


func _on_deck_start_game() -> void:
	_signals = get_parent()
	for child in play_area.get_children():
		child.visible = true
	_start_round()

func _start_round() -> void:
	if court_cards.size() == 0:
		player_won.emit()
		_signals.player_won.emit()
		return
	
	# draw boss
	boss = court_cards.pop_front()
	boss_deck_count.text = str(court_cards.size())
	boss_card.set_card_data(boss)
	
	# draw goons, jokers add extra
	_draw_goons()
	
	# determine weakest for Ace action cards
	# determine strongest for Ace/Joker logic and render
	_get_strongest_and_weakest_goon()
	_evaluate_goon_health()
	goon_row.show_goons(goons)
	health_row.show_health(goons_health)
	action_points = goons.size()
	ap_label.text = "AP: " + str(action_points)
	
	# bomb setup
	bomb_is_on = false
	bomb_was_used = false
	
	# Thinking. This may need to be triggered as part of _process to gracefully
	# handle Jokers
	_draw_action()
	new_round_started.emit(boss, health_slider.currentValue)
	_signals.new_round_started.emit(boss, health_slider.currentValue)

func _draw_action() -> void:
	if action_card.data != null and not action_card.data.rank == JOKER_RANK:
		discard_pile.append(action_card.data)
	
	action_card.set_card_data(_safe_draw())
	if action_card.data.rank == JOKER_RANK: #Joker
		action_points += 1
		ap_label.text = "AP: " + str(action_points)
		joker_drawn.emit()
		_signals.joker_drawn.emit()
		
		goons.append(action_card.data)
		goon_row.show_goons(goons)
		goons_health.append(strongest_goon.rank)
		health_row.show_health(goons_health)
		
		_draw_action()

func _draw_goons() -> void:
	goons = []
	var initial_goons = 4
	if boss.suit == CardData.Suit.DIAMONDS and boss.rank == 13:
		initial_goons = 6
	var goons_drawn = 0
	while goons_drawn < initial_goons:
		var card = _safe_draw()
		goons.append(card)
		if card.rank != JOKER_RANK or initial_goons == 6:
			goons_drawn += 1

func _safe_draw() -> CardData:
	if deck.size() <= 0:
		deck = discard_pile
		discard_pile = []
		DeckHelper.shuffle(deck)
	var top = deck.pop_front()
	deck_count.text = str(deck.size())
	return top

func _get_strongest_and_weakest_goon():
	for goon in goons:
		if goon.rank > 0:
			if strongest_goon == null or strongest_goon.rank < goon.rank:
				strongest_goon = goon
			# any goon except Aces and Jokers can be picked
			if (weakest_goon == null and goon.rank > 1) or (goon.rank > 1 and weakest_goon.rank > goon.rank):
				weakest_goon = goon
	
	if weakest_goon == null: # we drew all Aces and Jokers...
		# I almost feel like an easter egg should go here
		weakest_goon = goons[0]

func _evaluate_goon_health() -> void:
	goons_health = []
	for goon in goons:
		if goon.rank > 1:
			goons_health.append(goon.rank)
		else:
			goons_health.append(strongest_goon.rank)

# data is the target goon
func _on_goon_card_use_card(data: CardData, _button_index: int) -> void:
	var index = goons.find(data)
	if goons_health[index] <= 0:
		invalid_selection.emit()
		return # not valid
	
	if bomb_is_on:
		if _suit_matches_boss(goons[index]):
			invalid_selection.emit()
			return
		else:
			bomb_was_used = true
			bomb_is_on = false
			bomb_used.emit()
			_signals.bomb_used.emit()
			_update_goon_health(index, strongest_goon.rank)
	else:
		var dmg = 0
		
		# Ace, use weakest goon for dmg potential and rank
		var action_context_rank = _context_value(action_card.data, true)
		if action_context_rank <= _action_upper_limit(goons[index].rank):
			dmg = action_context_rank
		
		if dmg > 0:
			attacked.emit(goons[index], action_card.data)
			_signals.attacked.emit(goons[index], action_card.data)
			_update_goon_health(index, dmg)
		else:
			invalid_selection.emit()
			return
		# jokers shouldn't ever be assigned to action card

func _suit_matches_boss(goon: CardData) -> bool:
	return boss.same_suit(goon) or goon.rank == JOKER_RANK

func _on_action_points_decremented() -> void:
	if action_points > 0:
		_draw_action()
	else:
		_cleanup_round()

func _action_upper_limit(value: int) -> int:
	if value <= 1:
		return strongest_goon.rank + 3
	else:
		return value + 3

func _count_undefeated_goons() -> int:
	var count = 0
	for gh in goons_health:
		if gh > 0:
			count += 1
	return count

func _cleanup_round() -> void:
	var undefeated = _count_undefeated_goons()
	var dmg = undefeated
	if dmg > 0:
		dmg += (boss_card.data.rank - 11)
	
	if not bomb_was_used:
		dmg -= 1
	
	health_slider.change_value(-dmg)
	if health_slider.currentValue <= 0:
		player_died.emit()
		_signals.player_died.emit()
	
	goon_row.clear_goons()
	strongest_goon = null
	weakest_goon = null
	
	discard_pile.append_array(goons)
	goons = []
	goons_health = []
	
	_start_round()

func _update_goon_health(index: int, amount: int) -> void:
	goons_health[index] -= amount
	_decrement_ap_and_show_health()

func _decrement_ap_and_show_health() -> void:
	health_row.show_health(goons_health)
	_decrement_ap()

func _decrement_ap() -> void:
	action_points -= 1
	ap_label.text = "AP: " + str(action_points)
	_on_action_points_decremented()

func _on_skip_button_pressed() -> void:
	_decrement_ap()
