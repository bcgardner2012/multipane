extends Node
class_name HighLowGamePlayer

signal evaluate_guesses(prev_card: CardData, next_card: CardData)
signal game_started(first_card: CardData)

@export var deck_label: Label
@export var card_node: Card

@export var player1: HighLowPlayerControls
@export var player2: HighLowPlayerControls
@export var player3: HighLowPlayerControls
@export var player4: HighLowPlayerControls
@export var _signals: HighLowGamePane

var deck: Array[CardData]
var prev_card: CardData

func _ready() -> void:
	deck = []
	deck.append_array($CardDatas.get_children())
	DeckHelper.shuffle(deck)

func _on_deck_start_game() -> void:
	_draw_card()
	game_started.emit(card_node.data)
	# externalize
	_signals.game_started.emit()


# assuming only AI are playing, just draw and evaluate
func _on_card_use_card(_data: CardData, _button_index: int) -> void:
	if deck.size() == 0:
		return
	
	if player1.ai_enabled and player1.brain != null:
		prev_card = card_node.data
		_draw_card()
		evaluate_guesses.emit(prev_card, card_node.data)
	# else, you have to advance using the buttons, not the card

func _draw_card() -> void:
	card_node.visible = true
	var card = deck.pop_front()
	card_node.set_card_data(card)
	deck_label.text = str(deck.size())

func _on_player_controls_player_guessed(_guess: HighLowPlayerControls.Guess) -> void:
	if deck.size() == 0:
		return
	
	prev_card = card_node.data
	_draw_card()
	evaluate_guesses.emit(prev_card, card_node.data)

func _get_player_count() -> int:
	var c = 0
	if player1.visible:
		c += 1
	if player2.visible:
		c += 1
	if player3.visible:
		c += 1
	if player4.visible:
		c += 1
	return c
