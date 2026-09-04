extends Node
class_name HorseRaceGamePlayer

signal no_bet_error()
signal race_started()
signal race_ended(winner: CardData.Suit)

@export var links_node: Control
@export var drawn_card_node: Card
@export var bookie: HorseRaceBookie
@export var deck_count_label: Label

@export var club_horse: TextureRect
@export var diamond_horse: TextureRect
@export var heart_horse: TextureRect
@export var spade_horse: TextureRect

const BET_COUNT = 5
const START_CASH = 500
const MOTION_DELTA = Vector2(97.0, 0.0) # pixels
const WIN = 8
const CELEBRATION_TIME = 4.0 # seconds
var _timer: float

var _signals: HorseRaceGamePane

var _initial_horse_positions: Array[Vector2]
var _iterable_horses: Array[TextureRect]
var _suit_counts: Dictionary

var deck: Array[CardData]
var links: Array[CardData] # the positions in the race
var drawn_card: CardData

var is_bet_set: bool
var player_bet: int
var player_suit: CardData.Suit = CardData.Suit.CLUBS

var wallets: Array[int]

var club_count: int
var diamond_count: int
var heart_count: int
var spade_count: int

# cute name for a delay flag, to show the player who won briefly, then start next round
var is_celebrating: bool
var is_race_started: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_signals = get_parent()
	wallets = []
	for i in range(BET_COUNT):
		wallets.append(START_CASH)
	call_deferred("_after_all_ready")

func _after_all_ready() -> void:
	_initial_horse_positions = [
		club_horse.position,
		diamond_horse.position,
		heart_horse.position,
		spade_horse.position
	]
	_iterable_horses = [
		club_horse,
		diamond_horse,
		heart_horse,
		spade_horse
	]
	_setup_race()

# reset the celebration timer and flag so controls become responsive again
func _process(delta: float) -> void:
	if is_celebrating:
		_timer += delta
		if _timer >= CELEBRATION_TIME:
			is_celebrating = false
			_timer = 0.0
			_setup_race()

# recurses until we end up in a valid state
func _init_card_arrays() -> void:
	deck = []
	for c in $CardDatas.get_children():
		var card = c as CardData
		deck.append(card)
	DeckHelper.shuffle(deck)
	
	links = DeckHelper.multi_pop(deck, 7)
	_suit_counts = DeckHelper.get_suit_counts(links)
	var largest_count = 0
	for key in _suit_counts.keys():
		if largest_count < _suit_counts[key]:
			largest_count = _suit_counts[key]
	if largest_count > 4:
		_init_card_arrays()
	
	deck_count_label.text = str(deck.size())

func _setup_race() -> void:
	_init_card_arrays()
	for i in range(links_node.get_child_count()):
		var card_node = links_node.get_child(i) as Card
		card_node.set_card_data(links[i])
	for i in range(_iterable_horses.size()):
		_iterable_horses[i].position = _initial_horse_positions[i]
	drawn_card_node.reset_texture_and_data()

# the deck doesn't start the game this time, but clicking the deck still does stuff
func _on_deck_start_game() -> void:
	_on_deck_deck_clicked()


func _on_deck_deck_clicked() -> void:
	if is_celebrating:
		return
	
	if not is_bet_set:
		no_bet_error.emit()
		return
	
	if not is_race_started:
		is_race_started = true
		race_started.emit()
		_signals.race_started.emit()
	
	drawn_card = deck.pop_front()
	drawn_card_node.set_card_data(drawn_card)
	deck_count_label.text = str(deck.size())
	
	var winner = _move_horses()
	if winner != null:
		is_race_started = false
		is_celebrating = true
		_reset_counts()
		_handle_bets(winner)
		race_ended.emit(winner as CardData.Suit)

func _reset_counts() -> void:
	heart_count = 0
	diamond_count = 0
	club_count = 0
	spade_count = 0

func _handle_bets(winner: CardData.Suit) -> void:
	var mult = _bet_mult(_suit_counts[CardData.Suit.find_key(winner)])
	
	# npcs
	for i in range(1, wallets.size()):
		wallets[i] -= 25
	
	var npc_gain = 25 * (mult + 1)
	var npc_index = 0
	match winner:
		CardData.Suit.HEARTS:
			npc_index = 3
		CardData.Suit.DIAMONDS:
			npc_index = 2
		CardData.Suit.CLUBS:
			npc_index = 1
		CardData.Suit.SPADES:
			npc_index = 4
	
	wallets[npc_index] += npc_gain
	_signals.npc_won.emit(winner, wallets[npc_index])
	
	# player, done last to prioritize player's images
	if winner == player_suit:
		wallets[0] += player_bet * mult
		_signals.player_won.emit(wallets[0])
	else:
		wallets[0] -= player_bet
	
	bookie.update_cash_totals(wallets)

func _bet_mult(count: int) -> int:
	match count:
		0:
			return 1
		1:
			return 2
		2:
			return 3
		3:
			return 5
		4:
			return 10
	return 1

# returns null if no winner yet, or the card suit of the winner
func _move_horses():
	var winner = null
	match drawn_card.suit:
		CardData.Suit.HEARTS:
			heart_horse.position += MOTION_DELTA
			heart_count += 1
			if heart_count == WIN:
				winner = drawn_card.suit
		CardData.Suit.DIAMONDS:
			diamond_horse.position += MOTION_DELTA
			diamond_count += 1
			if diamond_count == WIN:
				winner = drawn_card.suit
		CardData.Suit.CLUBS:
			club_horse.position += MOTION_DELTA
			club_count += 1
			if club_count == WIN:
				winner = drawn_card.suit
		CardData.Suit.SPADES:
			spade_horse.position += MOTION_DELTA
			spade_count += 1
			if spade_count == WIN:
				winner = drawn_card.suit
	
	_signals.moved.emit(drawn_card.suit)
	return winner

func _on_text_edit_bet_set(bet: int) -> void:
	if not is_race_started:
		player_bet = bet
		is_bet_set = true


func _on_suit_suit_selected(suit: CardData.Suit) -> void:
	if not is_race_started:
		player_suit = suit
