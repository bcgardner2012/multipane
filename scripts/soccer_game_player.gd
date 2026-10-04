extends Node
class_name SoccerGamePlayer

signal final_half_started()
signal player_won()
signal player_lost()
signal tied()

@export var players_card_node: Card
@export var opponents_card_node: Card
@export var hand_h_box: HandHBox
@export var field: SoccerField
@export var player_score_label: Label
@export var opponent_score_label: Label

var hearts_hand: Array[CardData]
var spades_hand: Array[CardData]

var player_score: int
var opp_score: int

var cards_played: int # only counts player's cards
var is_final_half: bool

var _signals: SoccerGamePane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_signals = get_parent()
	
	hearts_hand = []
	for child in $Hearts.get_children():
		var card = child as CardData
		hearts_hand.append(card)
	
	_assemble_spades_hand()
	call_deferred("_assemble_hand_node")

func _assemble_hand_node() -> void:
	for i in range(hearts_hand.size()):
		var card = hand_h_box.get_child(i) as Card
		card.set_card_data(hearts_hand[i])
		card.visible = true
	hand_h_box._readjust()

func _assemble_spades_hand() -> void:
	spades_hand = []
	for child in $Spades.get_children():
		var card = child as CardData
		spades_hand.append(card)
	
	DeckHelper.shuffle(spades_hand)

func _on_card_use_card(data: CardData, _button_index: int) -> void:
	cards_played += 1
	hand_h_box._readjust()
	players_card_node.set_card_data(data)
	var opp_card = spades_hand.pop_front()
	opponents_card_node.set_card_data(opp_card)
	
	# result starts as int, becomes boolean
	var result = _compare(data, opp_card)
	var goal = false
	if result == 1:
		goal = field.move_right()
		if not goal:
			_signals.kicked.emit(data)
	elif result == -1:
		goal = field.move_left()
		if not goal:
			_signals.kicked.emit(opp_card)
	
	if goal:
		if result == 1:
			player_score += 1
			player_score_label.text = "Player: " + str(player_score)
			_signals.goal.emit(data)
		else:
			opp_score += 1
			opponent_score_label.text = "Opponent: " + str(opp_score)
			_signals.goal.emit(opp_card)
		field.reset()
	
	if cards_played == 13:
		if is_final_half:
			if player_score > opp_score:
				player_won.emit()
			elif player_score < opp_score:
				player_lost.emit()
			else:
				tied.emit()
		else:
			_assemble_hand_node()
			_assemble_spades_hand()
			is_final_half = true
			cards_played = 0
			final_half_started.emit()

# return 1 if player won, -1 if opp won, 0 if tied
func _compare(player_card: CardData, opp_card: CardData) -> int:
	if player_card.rank == 1 and opp_card.rank > 10:
		return 1
	elif player_card.rank > 10 and opp_card.rank == 1:
		return -1
	elif player_card.rank > opp_card.rank:
		return 1
	elif player_card.rank < opp_card.rank:
		return -1
	return 0
