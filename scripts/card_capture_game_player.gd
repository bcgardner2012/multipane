extends Node
class_name CardCaptureGamePlayer

# Phase 1 and 3 are handled automatically for expediency
const PHASE_2_LABEL = "Discard or continue with current hand"
const PHASE_4_LABEL = "Capture or sacrifice"
const REPLENISH_PHASE = 2
const CAPTURE_PHASE = 4

signal error_no_cards_selected()
signal error_sum_too_low()
signal error_two_jokers()
signal error_mixed_suit()
signal error_too_many_selected()
signal error_game_over()

@export var phase_label: Label
@export var enemy_zone: EnemyCardCaptureZone
@export var player_zone: PlayerCardCaptureZone

@export var player_deck_label: Label
@export var enemy_deck_label: Label

@onready var red_joker: CardData = $PlayerStarterDeck/RJOKER
@onready var black_joker: CardData = $PlayerStarterDeck/BJOKER

var enemy_deck: Array[CardData]
var player_deck: Array[CardData]

var enemy_discard: Array[CardData]
var player_discard: Array[CardData]

var enemy_hand: Array[CardData]
var player_hand: Array[CardData]

var selected_cards: Array[CardData]

var phase: int = CAPTURE_PHASE

var _signals: CardCaptureGamePane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_deck = []
	enemy_deck.append_array($CardDatas.get_children())
	DeckHelper.shuffle(enemy_deck)
	
	player_deck = []
	player_deck.append_array($PlayerStarterDeck.get_children())
	DeckHelper.shuffle(player_deck)
	
	enemy_discard = []
	player_discard = []
	enemy_hand = []
	player_hand = []
	selected_cards = []

func _process(_delta: float) -> void:
	player_deck_label.text = str(player_deck.size())
	enemy_deck_label.text = str(enemy_deck.size())

# enemy_deck starts with all but the face cards. Draw the first 4, then shuffle
# in the face cards 
func _on_deck_start_game() -> void:
	_signals = get_parent()
	
	for i in range(0, 4):
		enemy_hand.append(enemy_deck.pop_front())
		player_hand.append(player_deck.pop_front())
	
	enemy_deck.append_array($Royalty.get_children())
	DeckHelper.shuffle(enemy_deck)
	enemy_zone.populate(enemy_hand)
	
	player_zone.populate(player_hand)
	_populate_phase_label(PHASE_4_LABEL)

func _populate_phase_label(l: String) -> void:
	phase_label.text = l


func _on_player_use_card(data: CardData, button_index: int) -> void:
	if phase == CAPTURE_PHASE:
		_use_player_card_capture_mode(data, button_index)
	elif phase == REPLENISH_PHASE:
		_use_player_card_replenish_mode(data, button_index)

# here, we don't care about suit and rank checks, all selections are valid
func _use_player_card_replenish_mode(data: CardData, button_index: int) -> void:
	if button_index == MOUSE_BUTTON_LEFT:
		if not data in selected_cards:
			selected_cards.append(data)
		else:
			DeckHelper.remove_card(selected_cards, data)

func _use_player_card_capture_mode(data: CardData, button_index: int) -> void:
	if button_index == MOUSE_BUTTON_LEFT:
		if not data in selected_cards:
			selected_cards.append(data)
		else:
			DeckHelper.remove_card(selected_cards, data)

func _on_enemy_card_use_card(data: CardData, button_index: int) -> void:
	if button_index == MOUSE_BUTTON_LEFT:
		if selected_cards.size() <= 0:
			error_no_cards_selected.emit()
		elif _both_jokers_selected():
			error_two_jokers.emit()
		elif not _suits_match(data):
			error_mixed_suit.emit()
		else:
			var sum = _sum_selected_cards()
			if sum < data.rank:
				error_sum_too_low.emit()
			else:
				# do capture...
				# wipe cards from hand
				player_discard.append_array(selected_cards)
				player_zone.remove(selected_cards)
				DeckHelper.remove_cards(player_hand, selected_cards)
				selected_cards = []
				
				# wipe enemy and add to player discard
				player_discard.append(data)
				DeckHelper.remove_card(enemy_hand, data)
				
				# draw next enemy if available
				enemy_hand.push_front(enemy_deck.pop_front())
				enemy_zone.populate(enemy_hand)
				
				# next phase, discard and replenish
				phase = REPLENISH_PHASE
				_populate_phase_label(PHASE_2_LABEL)
				
				_signals.captured.emit(data, _determine_powerlevel())
		

func _sum_selected_cards() -> int:
	var sum = 0
	if _is_valid_joker_use():
		for card in selected_cards:
			if card.rank > 0: # not joker
				sum = card.rank * 2
	else:
		for card in selected_cards:
			sum += card.rank
	return sum

# won't reach here if both jokers selected, that step can be skipped
func _is_valid_joker_use() -> bool:
	var red_joker_selected = red_joker in selected_cards
	var black_joker_selected = black_joker in selected_cards
	var joker_selected = red_joker_selected or black_joker_selected
	return joker_selected and selected_cards.size() == 2

func _both_jokers_selected() -> bool:
	var red_joker_selected = red_joker in selected_cards
	var black_joker_selected = black_joker in selected_cards
	return red_joker_selected and black_joker_selected


func _on_discard_button_pressed() -> void:
	if phase == REPLENISH_PHASE:
		_replenish_player_hand()
		phase = CAPTURE_PHASE
		_populate_phase_label(PHASE_4_LABEL)
	elif phase == CAPTURE_PHASE:
		_sacrifice_selected()
		phase = REPLENISH_PHASE
		_populate_phase_label(PHASE_2_LABEL)

func _sacrifice_selected() -> void:
	if selected_cards.size() == 0:
		error_no_cards_selected.emit()
		return
	elif selected_cards.size() == 1:
		# if any discards are royalty, game over
		if selected_cards[0].rank >= 11 or enemy_hand[enemy_hand.size()-1].rank >= 11:
			error_game_over.emit()
			return
		
		# remove rightmost enemy from play
		enemy_hand.pop_back()
	elif selected_cards.size() == 2:
		# if any discards are royalty, game over
		if selected_cards[0].rank >= 11 or selected_cards[1].rank >= 11:
			error_game_over.emit()
			return
		
		# move rightmost enemy to bottom of deck
		enemy_deck.push_back(enemy_hand.pop_back())
	else:
		# Too many selected
		error_too_many_selected.emit()
		return
	
	_update_hands_for_sacrifice()

func _update_hands_for_sacrifice() -> void:
	DeckHelper.remove_cards(player_hand, selected_cards)
	enemy_hand.push_front(enemy_deck.pop_front())
	enemy_zone.populate(enemy_hand)
	for sc in selected_cards:
		# not clicking cards to trigger this, should be no fuckery
		player_zone._unhighlight(sc)
	player_zone.remove(selected_cards)
	selected_cards = []

func _replenish_player_hand() -> void:
	if selected_cards.size() > 0:
		# wipe cards from hand
		player_discard.append_array(selected_cards)
		DeckHelper.remove_cards(player_hand, selected_cards)
		selected_cards = []
	
	# pull missing cards from deck, or shuffle discard into deck if can't
	var drawn = DeckHelper.multi_pop(player_deck, mini(4 - player_hand.size(), player_deck.size()))
	player_hand.append_array(drawn)
	if player_deck.size() <= 0:
		DeckHelper.shuffle(player_discard)
		player_deck = player_discard
		player_discard = []
		if player_hand.size() < 4:
			drawn = DeckHelper.multi_pop(player_deck, mini(4 - player_hand.size(), player_deck.size()))
			player_hand.append_array(drawn)
	
	player_zone.populate(player_hand)

func _suits_match(enemy: CardData) -> bool:
	for card in selected_cards:
		if not card.same_suit(enemy) and card.rank != 0:
			return false
	return true

# as average rank of all player cards
func _determine_powerlevel() -> int:
	var powerlevel = 0
	for c in player_hand:
		powerlevel += c.rank
	for c in player_deck:
		powerlevel += c.rank
	for c in player_discard:
		powerlevel += c.rank
	
	return powerlevel / (player_deck.size() + player_hand.size() + player_discard.size())
