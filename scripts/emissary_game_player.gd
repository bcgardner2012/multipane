extends Node
class_name EmissaryGamePlayer

signal invalid_card_play()
signal jack_out_of_phase()
signal no_clubs_in_hand_error()
signal same_kingdom_spades_error()
signal last_kingdom_spades_error()

signal debate_started(kingdom: CardData, drawn_card: CardData)
signal kingdom_won(kingdom: CardData)
signal phase_changed(phase: Phase)
signal card_played_from_hand(card: CardData)
signal game_lost(kingdom: CardData)
signal heart_advisor_used(to_remove: Array[CardData])
signal diamond_advisor_used(drawn_cards: Array[CardData])
signal do_diamond_discard(discards: Array[CardData])
signal club_advisor_used(drawn_cards: Array[CardData])
signal spade_advisor_used(prev: CardData, next: CardData)

signal externalize_card_play(kingdom: CardData, won: bool, card: CardData)

@export var kingdoms_node: EmissaryKingdoms
@export var advisors_node: Control
@export var hand_node: EmissaryHand
@export var win_count_label: Label
@export var loss_count_label: Label
@export var ability_uses_node: EmissaryAbilityUsesRemainingLabels
@export var deck_label: Label

var deck: Array[CardData]
var nobles: Array[CardData]
var jacks: Array[CardData]
var hand: Array[CardData]

var active_kingdom: CardData
var topic: CardData
var kingdoms_visited: Array[CardData]

enum Phase {
	BetweenDebates,
	SeekingAdvice,
	PlayerTurn,
	DiamondJackAwaiting,
	SpadeJackAwaiting,
	GameOver
}
var phase: Phase
var wins: int
var losses: int
var wins_required: int

##### Advisors #####
# pop_front when an advisor is used, re-add the Jack on win debate
# size determines how many times an ability can be used
var heart_advisors: Array[CardData]
var diamond_advisors: Array[CardData]
var club_advisors: Array[CardData]
var spade_advisors: Array[CardData]

# If == 0, do nothing. If >= 1, prepend Jack. Reset on win debate.
var heart_ability_usages: int
var diamond_ability_usages: int
var club_ability_usages: int
var spade_ability_usages: int

# when size reaches 2, perform discard and change phase
var diamond_pending_discards: Array[CardData]
##### Advisors #####

func _ready() -> void:
	_reset_deck()
	
	nobles = []
	for card in $RoyalCards.get_children():
		nobles.append(card)
	DeckHelper.shuffle(nobles)
	
	jacks = []
	for card in $Jacks.get_children():
		jacks.append(card)
	DeckHelper.shuffle(jacks)
	
	heart_advisors = [$Jacks/HJ]
	diamond_advisors = [$Jacks/DJ]
	club_advisors = [$Jacks/CJ]
	spade_advisors = [$Jacks/SJ]
	
	hand = []
	diamond_pending_discards = []
	kingdoms_visited = []

func _on_deck_start_game() -> void:
	# distribute kingdoms/nobles
	var i = 0
	for card_holder in kingdoms_node.get_children():
		var card = card_holder.get_child(0) as Card
		card.set_card_data(nobles[i])
		i += 1
	
	# draw hand
	_draw_hand()
	
	deck_label.text = str(deck.size())
	phase = Phase.BetweenDebates


# valid phases: Between, SpadeJack
func _on_kingdom_card_use_card(data: CardData, button_index: int) -> void:
	if (phase != Phase.BetweenDebates and phase != Phase.SpadeJackAwaiting) or button_index != MOUSE_BUTTON_LEFT:
		return
	
	if phase == Phase.BetweenDebates:
		# set data as active kingdom
		active_kingdom = data
		kingdoms_visited.append(active_kingdom)
		wins_required = kingdoms_node.get_wins_required(active_kingdom)
		# spawn a stacked card on top of the kingdom
		var drawn_card = _draw_card()
		topic = drawn_card
		debate_started.emit(active_kingdom, drawn_card)
		_change_phase(Phase.SeekingAdvice)
	
	elif phase == Phase.SpadeJackAwaiting:
		# should have selected a different kingdom than the active
		if data.equals(active_kingdom):
			same_kingdom_spades_error.emit()
			return
		# should not be the last kingdom... shouldn't even reach here
		if kingdoms_visited.size() == 7:
			last_kingdom_spades_error.emit()
			return
		spade_advisor_used.emit(active_kingdom, data)
		active_kingdom = data
		_change_phase(Phase.SeekingAdvice)

func _draw_card() -> CardData:
	var c = deck.pop_front()
	deck_label.text = str(deck.size())
	return c


func _on_hand_card_use_card(data: CardData, button_index: int) -> void:
	if phase != Phase.PlayerTurn and phase != Phase.DiamondJackAwaiting:
		return
	
	if phase == Phase.PlayerTurn and button_index == MOUSE_BUTTON_LEFT:
		# Validate the card
		if not _is_valid_card_play(data):
			invalid_card_play.emit()
			return
		# increment win/loss
		# if same suit and higher rank, win
		var same_suit = topic.same_suit(data)
		var won = true
		if same_suit and data.rank > topic.rank:
			wins += 1
			win_count_label.text = "W: " + str(wins)
		elif not same_suit and not topic.same_suit(active_kingdom) and data.same_suit(active_kingdom):
			# changed topic to ruler's preffered suit
			wins += 1
			win_count_label.text = "W: " + str(wins)
		else:
			losses += 1
			loss_count_label.text = "L: " + str(losses)
			won = false
		
		# draw kingdom's card, facedown, and cleanup
		card_played_from_hand.emit(data)
		externalize_card_play.emit(active_kingdom, won, data)
		DeckHelper.remove_card(hand, data)
		if hand.size() > 0:
			var drawn_card = _draw_card()
			topic = drawn_card
			debate_started.emit(active_kingdom, drawn_card)
			_change_phase(Phase.SeekingAdvice)
		elif wins == wins_required:
			_do_kingdom_won()
		else:
			game_lost.emit(active_kingdom)
			_change_phase(Phase.GameOver)
	elif phase == Phase.DiamondJackAwaiting:
		diamond_pending_discards.append(data)
		if diamond_pending_discards.size() == 2:
			for pending_discard in diamond_pending_discards:
				DeckHelper.remove_card(hand, pending_discard)
			do_diamond_discard.emit(diamond_pending_discards)
			diamond_pending_discards = []
			_change_phase(Phase.SeekingAdvice)

func _is_valid_card_play(data: CardData) -> bool:
	# must play a card of the same suit as topic if possible
	if topic.same_suit(data):
		return true
	elif DeckHelper.contains_suit(hand, topic.suit):
		return false
	# if can't, then any card may be played
	return true

func _on_kingdoms_kingdom_card_flipped(_kingdom: CardData, _flipped_card: CardData) -> void:
	# should only be possible during SeekingAdvice
	if phase != Phase.SeekingAdvice:
		print("A kingdom card was flipped outside the Advice phase, " + str(phase))
		return
	
	# card flips automatically
	# set phase to player turn
	_change_phase(Phase.PlayerTurn)

func _recruit_ruler() -> void:
	match active_kingdom.suit:
		CardData.Suit.HEARTS:
			heart_advisors.append(active_kingdom)
		CardData.Suit.DIAMONDS:
			diamond_advisors.append(active_kingdom)
		CardData.Suit.CLUBS:
			club_advisors.append(active_kingdom)
		CardData.Suit.SPADES:
			spade_advisors.append(active_kingdom)

func _reset_advisors() -> void:
	if heart_ability_usages > 0:
		heart_ability_usages = 0
		heart_advisors.push_front($Jacks/HJ)
	if diamond_ability_usages > 0:
		diamond_ability_usages = 0
		diamond_advisors.push_front($Jacks/DJ)
	if club_ability_usages > 0:
		club_ability_usages = 0
		club_advisors.push_front($Jacks/CJ)
	if spade_ability_usages > 0:
		spade_ability_usages = 0
		spade_advisors.push_front($Jacks/SJ)
	
	_set_ability_labels()

func _set_ability_labels() -> void:
	ability_uses_node.set_labels(heart_advisors.size(), diamond_advisors.size(), club_advisors.size(), spade_advisors.size())

func _on_heart_advisor_card_use_card(_data: CardData, button_index: int) -> void:
	if phase != Phase.SeekingAdvice:
		jack_out_of_phase.emit()
		return
	
	if button_index == MOUSE_BUTTON_LEFT and heart_advisors.size() > 0:
		heart_advisors.pop_front()
		heart_ability_usages += 1
		
		# discard all cards in hand of the kingdom suit
		var marked_for_removal: Array[CardData] = []
		for card in hand:
			if card.same_suit(active_kingdom):
				marked_for_removal.append(card)
		
		heart_advisor_used.emit(marked_for_removal)
		for card in marked_for_removal:
			DeckHelper.remove_card(hand, card)
		
		_set_ability_labels()
		
		if hand.size() == 0:
			if wins == wins_required:
				_do_kingdom_won()
			else:
				game_lost.emit(active_kingdom)
				_change_phase(Phase.GameOver)


func _on_diamond_advisor_card_use_card(_data: CardData, button_index: int) -> void:
	if phase != Phase.SeekingAdvice:
		jack_out_of_phase.emit()
		return
	
	if button_index == MOUSE_BUTTON_LEFT and diamond_advisors.size() > 0:
		diamond_advisors.pop_front()
		diamond_ability_usages += 1
		
		var drawn_cards: Array[CardData] = [_draw_card(), _draw_card()]
		hand.append_array(drawn_cards)
		diamond_advisor_used.emit(drawn_cards)
		
		_change_phase(Phase.DiamondJackAwaiting)
		# logic for discarding needs to be handled elsewhere since card callbacks are used...
		
		_set_ability_labels()


func _on_club_advisor_card_use_card(_data: CardData, button_index: int) -> void:
	if phase != Phase.SeekingAdvice:
		jack_out_of_phase.emit()
		return
	if not DeckHelper.contains_suit(hand, CardData.Suit.CLUBS):
		no_clubs_in_hand_error.emit()
		return 
	
	if button_index == MOUSE_BUTTON_LEFT and club_advisors.size() > 0:
		club_advisors.pop_front()
		club_ability_usages += 1
		
		var draw_count = 0
		for card in hand:
			if card.suit == CardData.Suit.CLUBS:
				draw_count += 1
		var drawn_cards: Array[CardData] = []
		for i in range(0, draw_count):
			drawn_cards.append(_draw_card())
		
		hand.append_array(drawn_cards)
		club_advisor_used.emit(drawn_cards)
		
		_set_ability_labels()


func _on_spade_advisor_card_use_card(_data: CardData, button_index: int) -> void:
	if phase != Phase.SeekingAdvice:
		jack_out_of_phase.emit()
		return
	if kingdoms_visited.size() >= 7:
		last_kingdom_spades_error.emit()
		return
	
	if button_index == MOUSE_BUTTON_LEFT and spade_advisors.size() > 0:
		spade_advisors.pop_front()
		spade_ability_usages += 1
		
		_change_phase(Phase.SpadeJackAwaiting)
		# logic for selecting kingdoms to swap requires kingdom card click, must be handled elsewhere
		
		_set_ability_labels()

func _change_phase(p: Phase) -> void:
	phase = p
	phase_changed.emit(phase)

func _do_kingdom_won() -> void:
	_recruit_ruler()
	_reset_advisors()
	kingdom_won.emit(active_kingdom)
	_change_phase(Phase.BetweenDebates)
	_reset_deck()
	_draw_hand()
	
	wins = 0
	losses = 0
	win_count_label.text = "W: " + str(wins)
	loss_count_label.text = "L: " + str(losses)
	
func _reset_deck() -> void:
	deck = []
	for card in $CardDatas.get_children():
		deck.append(card)
	DeckHelper.shuffle(deck)

func _draw_hand() -> void:
	for i in range(0, 8):
		var card_holder = hand_node.get_child(i) as CardHighlighter
		card_holder.visible = true
		card_holder._unhighlight()
		var card = card_holder.get_child(0) as Card
		var drawn_card = deck.pop_front()
		hand.append(drawn_card)
		card.set_card_data(drawn_card)
