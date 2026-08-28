extends Control
class_name WarTieBreaker

# card to check, next_index to use in case of another tie (bring other tiebreaker into sync)
signal do_tiebreak(card: CardData, next_index: int)

var index: int

const TIE_DELAY = 1.5
var _timer = 0.0
var queue_tie_resolved: bool

# add a delay before hiding tiebreaker and resetting is_tied
func _process(delta: float) -> void:
	if queue_tie_resolved:
		_timer += delta
		if _timer > TIE_DELAY:
			_timer = 0.0
			_do_reset()

func start_tiebreak(deck: Array[CardData]) -> void:
	visible = true
	var until = mini(deck.size(), 4)
	index = until - 1 # used to index into children
	for i in range(0, until):
		var card = get_child(i) as Card
		card.reset_texture_and_data()
		card.is_facedown = true
		card.set_card_data(deck.pop_front())
		card.visible = true
	
	var next_card = get_child(index) as Card
	next_card.mouse_filter = Control.MOUSE_FILTER_PASS

# because we are messing with mouse_filter, only the last card is clickable
func _on_card_card_flipped(data: CardData, _button_index: int) -> void:
	index -= 1
	do_tiebreak.emit(data, index)

# call directly, not via signal registry
func pop_card() -> CardData:
	var card = get_child(index) as Card
	card.flip()
	index -= 1
	return card.data

func reset() -> void:
	queue_tie_resolved = true

func _do_reset() -> void:
	index = 0
	for child in get_children():
		var card = child as Card
		card.visible = false
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.reset_texture_and_data()
		card.is_facedown = true
	visible = false
	queue_tie_resolved = false
