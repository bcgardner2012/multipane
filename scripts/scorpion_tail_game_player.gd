extends Node
class_name ScorpionTailGamePlayer

signal tail_cannot_start_with_ace()
signal must_play_lower_rank()

@onready var overlapable_card_scene = preload("res://scenes/overlapable_card.tscn")

@export var hand: HandHBox
@export var tail_node: ScorpionTailTailNode
@export var npc_hand_label: Label
@export var deck_count_label: Label

var deck: Array[CardData]
var player_hand: Array[CardData]
var npc_hand: Array[CardData]
var tail: Array[CardData]

var _signals: ScorpionTailGamePane

func _ready() -> void:
	deck = []
	deck.append_array($CardDatas.get_children())
	DeckHelper.shuffle(deck)
	
	tail = []

func _on_deck_start_game() -> void:
	_signals = get_parent()
	player_hand = DeckHelper.multi_pop(deck, 5)
	npc_hand = DeckHelper.multi_pop(deck, 5)
	_update_hand_node()

# TODO: if player_hand.size ==0 at any point, player wins
func _on_card_use_card(data: CardData, button_index: int) -> void:
	if button_index == MOUSE_BUTTON_LEFT:
		# starting a new tail?
		if tail.size() == 0:
			if data.rank > 1:
				tail.append(data)
				tail_node.update(tail)
				_remove_from_hand(data)
				_signals.tail_grew.emit(tail)
				_do_npc_turn()
			else:
				tail_cannot_start_with_ace.emit()
		# adding on to tail?
		else:
			var last = tail.size()-1
			if data.rank < tail[last].rank:
				# aces terminate a tail
				if data.rank == 1:
					# special behavior
					npc_hand.append_array(tail)
					tail = []
					tail_node.update(tail)
					_signals.tail_stung.emit(tail, false)
					# shuffle ace back into deck
					deck.append(data)
					DeckHelper.shuffle(deck)
				else:
					tail.append(data)
					tail_node.update(tail)
					_signals.tail_grew.emit(tail)
				_remove_from_hand(data)
				_do_npc_turn()
			else:
				must_play_lower_rank.emit()

func _remove_from_hand(data: CardData) -> void:
	DeckHelper.remove_card(player_hand, data)
	for child in hand.get_children():
		var child_card = child as Card
		if child_card.data.equals(data):
			child_card.queue_free()

# just play the highest possible card. Failing that, just draw one.
func _do_npc_turn() -> void:
	var highest_card: CardData = null
	
	# play highest card
	if tail.size() == 0:
		for card in npc_hand:
			if highest_card == null or highest_card.rank < card.rank:
				highest_card = card
	# play highest card less than last in tail
	else:
		for card in npc_hand:
			var card_less_tail = card.rank < tail[tail.size()-1].rank
			if (highest_card == null or highest_card.rank < card.rank) and card_less_tail:
				highest_card = card
	
	if highest_card != null:
		if highest_card.rank == 1:
			player_hand.append_array(tail)
			deck.append(highest_card)
			DeckHelper.shuffle(deck)
			_update_hand_node()
			tail = []
			tail_node.update(tail)
			_signals.tail_stung.emit(tail, true)
		
		# add to tail
		else:
			tail.append(highest_card)
			tail_node.update(tail)
			_signals.tail_grew.emit(tail)
		DeckHelper.remove_card(npc_hand, highest_card)
	else:
		# draw from deck
		npc_hand.append(deck.pop_front())
	
	npc_hand_label.text = "NPC Hand: " + str(npc_hand.size()) + " cards"
	deck_count_label.text = str(deck.size())
	
	# TODO: if npc_hand.size() == 0, npc wins

# The player is trying to draw a card and pass turn to NPC
func _on_deck_deck_clicked() -> void:
	player_hand.append(deck.pop_front())
	deck_count_label.text = str(deck.size())
	_update_hand_node()
	_do_npc_turn()

func _update_hand_node() -> void:
	for child in hand.get_children():
		child.queue_free()
	for card_data in player_hand:
		var card = overlapable_card_scene.instantiate() as Card
		card.set_card_data(card_data)
		card.use_card.connect(_on_card_use_card)
		hand.add_child(card)
