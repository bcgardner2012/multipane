extends Node
class_name MrPresidentGamePlayer

const RANK_TO_REGION = {
	2: 2,
	3: 3,
	4: 4,
	5: 5,
	6: 5,
	7: 5,
	8: 6,
	9: 6,
	10: 6,
	11: 7,
	12: 7,
	13: 7,
	14: 7
}

@export var player_hand_node: HandHBox
@export var board: MrPresidentBoard
@export var player_card_node: Card
@export var spade_card_node: Card
@export var diamond_card_node: Card
@export var remaining_votes_label: Label
@export var player_score_label: Label
@export var spade_score_label: Label
@export var diamond_score_label: Label

var club_deck: Array[CardData]
var spade_deck: Array[CardData]
var diamond_deck: Array[CardData]
var heart_deck: Array[CardData] # this is the player's deck

var club_card: CardData
var remaining_votes: int = 27
var player_score: int
var spade_score: int
var diamond_score: int

var _signals: MrPresidentGamePane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_signals = get_parent()
	
	club_deck = []
	spade_deck = []
	diamond_deck = []
	heart_deck = []
	
	DeckHelper.init_deck(club_deck, $Clubs, true)
	DeckHelper.init_deck(spade_deck, $Spades, true)
	DeckHelper.init_deck(diamond_deck, $Diamonds, true)
	DeckHelper.init_deck(heart_deck, $Hearts, false)
	
	call_deferred("_assemble_hand_node")
	call_deferred("_draw_club")

func _assemble_hand_node() -> void:
	player_hand_node.assemble(heart_deck)

func _draw_club() -> void:
	if club_deck.size() <= 0:
		return
	club_card = club_deck.pop_front()
	board.highlight(club_card)


func _on_card_use_card(data: CardData, _button_index: int) -> void:
	# draw and update displays
	player_card_node.set_card_data(data)
	var spade_card = spade_deck.pop_front()
	spade_card_node.set_card_data(spade_card)
	var diamond_card = diamond_deck.pop_front()
	diamond_card_node.set_card_data(diamond_card)
	
	# get round winner
	var round_winner = club_card
	if data.rank > spade_card.rank and data.rank > diamond_card.rank:
		board.set_area_winner(club_card, data)
		round_winner = data
	elif spade_card.rank > data.rank and spade_card.rank > diamond_card.rank:
		board.set_area_winner(club_card, spade_card)
		round_winner = spade_card
	elif diamond_card.rank > data.rank and diamond_card.rank > spade_card.rank:
		board.set_area_winner(club_card, diamond_card)
		round_winner = diamond_card
	
	# see if region winner changed and update scores and displays
	_compute_scores()
	
	if heart_deck.size() == 0:
		_signals.game_over.emit(_get_president())
	else:
		_signals.round_end.emit(round_winner, RANK_TO_REGION[club_card.rank])
	
	# draw another club card to start next round
	_draw_club()

func _compute_scores() -> void:
	remaining_votes = 0
	player_score = 0
	spade_score = 0
	diamond_score = 0
	for i in range(2, 8):
		var region_winner = board.get_region_winner(i)
		match region_winner:
			CardData.Suit.HEARTS:
				player_score += i
			CardData.Suit.DIAMONDS:
				diamond_score += i
			CardData.Suit.SPADES:
				spade_score += i
			CardData.Suit.CLUBS:
				remaining_votes += i
	
	remaining_votes_label.text = "Remaining Votes: " + str(remaining_votes)
	player_score_label.text = "Player: " + str(player_score)
	spade_score_label.text = "Spade: " + str(spade_score)
	diamond_score_label.text = "Diamond: " + str(diamond_score)

func _get_president() -> CardData.Suit:
	if player_score > spade_score and player_score > diamond_score:
		return CardData.Suit.HEARTS
	elif spade_score > player_score and spade_score > diamond_score:
		return CardData.Suit.SPADES
	elif diamond_score > player_score and diamond_score > spade_score:
		return CardData.Suit.DIAMONDS
	return CardData.Suit.CLUBS
