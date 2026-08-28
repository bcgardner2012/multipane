extends Node
class_name WarGamePlayer

@export var red_deck_label: Label
@export var blue_deck_label: Label
@export var red_card_node: Card
@export var blue_card_node: Card
@export var red_score_label: Label
@export var blue_score_label: Label
@export var red_tiebreaker: WarTieBreaker
@export var blue_tiebreaker: WarTieBreaker
@export var signals: WarGamePane

var all_cards: Array[CardData]
var red_deck: Array[CardData]
var blue_deck: Array[CardData]

var red_score: int
var blue_score: int

func _ready() -> void:
	all_cards = []
	all_cards.append_array($CardDatas.get_children())
	DeckHelper.shuffle(all_cards)
	
	red_deck = []
	@warning_ignore("integer_division")
	for i in range(0, all_cards.size() / 2):
		red_deck.append(all_cards[i])
	blue_deck = []
	@warning_ignore("integer_division")
	for i in range(all_cards.size() / 2, all_cards.size()):
		blue_deck.append(all_cards[i])

const TIE_DELAY = 1.5
var _timer = 0.0
var is_tied: bool
var queue_tie_resolved: bool

# add a delay before hiding tiebreaker and resetting is_tied
func _process(delta: float) -> void:
	if queue_tie_resolved:
		_timer += delta
		if _timer > TIE_DELAY:
			_timer = 0.0
			queue_tie_resolved = false
			is_tied = false

func _on_deck_start_game() -> void:
	_draw_next_cards()
	signals.game_started.emit()

func _on_red_card_card_flipped(_data: CardData, _button_index: int) -> void:
	blue_card_node.flip()
	_determine_round_winner()


func _on_blue_card_card_flipped(_data: CardData, _button_index: int) -> void:
	red_card_node.flip()
	_determine_round_winner()

func _determine_round_winner() -> void:
	if blue_card_node.data.rank > red_card_node.data.rank:
		_increment_blue_score(1)
	elif blue_card_node.data.rank < red_card_node.data.rank:
		_increment_red_score(1)
	else:
		is_tied = true
		signals.round_tied.emit(red_score, blue_score)
		red_tiebreaker.start_tiebreak(red_deck)
		blue_tiebreaker.start_tiebreak(blue_deck)

func _on_red_card_use_card(_data: CardData, _button_index: int) -> void:
	# you must resolve ties before continuing
	if not is_tied and red_deck.size() > 0:
		_draw_next_cards()
		_determine_round_winner()
		if red_deck.size() <= 0:
			signals.game_over.emit(red_score, blue_score)


func _on_blue_card_use_card(_data: CardData, _button_index: int) -> void:
	# you must resolve ties before continuing
	if not is_tied and blue_deck.size() > 0:
		_draw_next_cards()
		_determine_round_winner()
		if blue_deck.size() <= 0:
			signals.game_over.emit(red_score, blue_score)

func _draw_next_cards() -> void:
	var red_card = red_deck.pop_front()
	red_deck_label.text = str(red_deck.size())
	red_card_node.set_card_data(red_card)
	red_card_node.visible = true
	
	var blue_card = blue_deck.pop_front()
	blue_deck_label.text = str(blue_deck.size())
	blue_card_node.set_card_data(blue_card)
	blue_card_node.visible = true

func _increment_red_score(amount: int) -> void:
	red_score += amount
	red_score_label.text = "Score: " + str(red_score)
	signals.round_won.emit(true, red_score, blue_score)

func _increment_blue_score(amount: int) -> void:
	blue_score += amount
	blue_score_label.text = "Score: " + str(blue_score)
	signals.round_won.emit(false, red_score, blue_score)

func _reset_tiebreakers() -> void:
	blue_tiebreaker.reset()
	red_tiebreaker.reset()
	queue_tie_resolved = true

func _on_red_tiebreaker_do_tiebreak(card: CardData, next_index: int) -> void:
	var blue_card = blue_tiebreaker.pop_card()
	if card.rank > blue_card.rank:
		_increment_red_score(5)
		_reset_tiebreakers()
	elif card.rank < blue_card.rank:
		_increment_blue_score(5)
		_reset_tiebreakers()
	else:
		_resolve_multiple_ties(next_index)

func _on_blue_tiebreaker_do_tiebreak(card: CardData, next_index: int) -> void:
	var red_card = red_tiebreaker.pop_card()
	if card.rank > red_card.rank:
		_increment_blue_score(5)
		_reset_tiebreakers()
	elif card.rank < red_card.rank:
		_increment_red_score(5)
		_reset_tiebreakers()
	else:
		_resolve_multiple_ties(next_index)

func _resolve_multiple_ties(next_index: int) -> void:
	var tie_resolved = false
	for i in range(0, next_index):
		var bc = blue_tiebreaker.pop_card()
		var rc = red_tiebreaker.pop_card()
		if bc.rank > rc.rank:
			_increment_blue_score(5)
			_reset_tiebreakers()
			tie_resolved = true
		elif bc.rank < rc.rank:
			_increment_red_score(5)
			_reset_tiebreakers()
			tie_resolved = true
		# else, continue...
	if not tie_resolved:
		# all cards were tied
		_reset_tiebreakers()
