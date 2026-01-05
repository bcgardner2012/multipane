extends Node
class_name ZombieDiceGamePlayer

signal hit_three_times()
signal game_won()
signal game_lost()

@export var human_slots: ZombieDiceHumanSlots
@export var action_slots: ZombieDiceActionSlots
@export var pending_brains_label: Label
@export var pending_bullets_label: Label
@export var score_label: Label
@export var round_label: Label
@export var injury_label: Label
@export var bullets_taken_label: Label

@export var draw_button: Button
@export var stop_button: Button
@export var endless_button: Button

# check ranks. 10 and 11 are easy, 12 is med, 13 is hard
# pop and push_back to cycle through all humans as round drags on
# shuffle at end of round.
var human_deck: Array[CardData]

# access action decks by random index, no need to pop or push or shuffle
var green_action_deck: Array[CardData]
var yellow_action_deck: Array[CardData]
var red_action_deck: Array[CardData]

var active_humans: Array[CardData]
var active_actions: Array[CardData]

var _round: int
var score: int
var pending_brains: int
var pending_bullets: int
var injury_count: int
var bullets_taken: int

var endless_mode_enabled: bool

func _ready() -> void:
	randomize()
	
	human_deck = []
	human_deck.append_array($Humans.get_children())
	DeckHelper.shuffle(human_deck)
	
	green_action_deck = []
	green_action_deck.append_array($EasyDeck.get_children())
	DeckHelper.shuffle(green_action_deck)
	
	yellow_action_deck = []
	yellow_action_deck.append_array($MedDeck.get_children())
	DeckHelper.shuffle(yellow_action_deck)
	
	red_action_deck = []
	red_action_deck.append_array($HardDeck.get_children())
	DeckHelper.shuffle(red_action_deck)
	
	active_actions = []
	active_humans = []
	
	_round = 0

func _on_human_deck_start_game() -> void:
	_setup_next_round()
	draw_button.visible = true
	stop_button.visible = true

func _setup_next_round() -> void:
	_cleanup_round()
	DeckHelper.shuffle(human_deck)
	active_humans = _pop_front_array()
	human_slots.populate(active_humans)
	_draw_actions()
	_record_brains_and_bullets()
	
	_round += 1
	round_label.text = "Round: " + str(_round)
	
	if ZombieDiceSettings.lose_condition == ZombieDiceSettings.ZombieDiceLoseCondition.ROUNDS_PASSED:
		if _round > ZombieDiceSettings.lose_condition_count and score < ZombieDiceSettings.win_condition_brain_count and not endless_mode_enabled:
			game_lost.emit()

# Caution: pop, do processing, then push back all cards
func _pop_front_array() -> Array[CardData]:
	return [human_deck.pop_front(), human_deck.pop_front(), human_deck.pop_front()]

# Caution: pop first, do processing, then push back all cards
func _push_back_array(humans: Array[CardData]) -> void:
	human_deck.push_back(humans[0])
	human_deck.push_back(humans[1])
	human_deck.push_back(humans[2])

# do this frequently to keep odds of each action appropriate
func _shuffle_action_decks() -> void:
	DeckHelper.shuffle(green_action_deck)
	DeckHelper.shuffle(yellow_action_deck)
	DeckHelper.shuffle(red_action_deck)

func _get_flee_count() -> int:
	var c = 0
	for action in active_actions:
		if action.suit == CardData.Suit.SPADES:
			c += 1
	return c

func _get_brain_count() -> int:
	var c = 0
	for action in active_actions:
		if action.suit == CardData.Suit.HEARTS:
			c += 1
	return c

func _get_bullet_count() -> int:
	var c = 0
	for action in active_actions:
		if action.suit == CardData.Suit.CLUBS:
			c += 1
	return c

func _replace_non_fleeing_humans(humans: Array[CardData]) -> void:
	var j = 0
	for i in range(0, 3):
		var active_human = active_humans[i]
		var active_action = active_actions[i]
		if active_action.suit != CardData.Suit.SPADES and j < humans.size():
			human_deck.push_back(active_human)
			active_humans[i] = humans[j]
			j += 1

func _draw_actions() -> void:
	var actions: Array[CardData] = []
	for human in active_humans:
		var r = randi() % 6
		var action: CardData = null
		if human.rank <= 11:
			action = green_action_deck[r]
		elif human.rank == 12:
			action = yellow_action_deck[r]
		elif human.rank == 13:
			action = red_action_deck[r]
		actions.append(action)
	
	active_actions = actions
	action_slots.populate(actions)

func _record_brains_and_bullets() -> void:
	var bullet_count = _get_bullet_count()
	
	pending_brains += _get_brain_count()
	pending_bullets += bullet_count
	pending_brains_label.text = str(pending_brains)
	pending_bullets_label.text = str(pending_bullets)
	bullets_taken += bullet_count
	bullets_taken_label.text = "Bullets Taken: " + str(bullets_taken)

# draw 3 - flee cards, add pending values, check for 3 bullets
func _on_draw_again_button_pressed() -> void:
	# get active humans that don't have a flee card
	var draw_count = 3 - _get_flee_count()
	var humans: Array[CardData] = []
	for i in range(0, draw_count):
		humans.append(human_deck.pop_front())
	
	# re-draw those humans
	_replace_non_fleeing_humans(humans)
	human_slots.populate(humans)
	
	# draw all actions
	_draw_actions()
	
	# calculate pending states
	_record_brains_and_bullets()
	if ZombieDiceSettings.lose_condition == ZombieDiceSettings.ZombieDiceLoseCondition.BULLETS_TAKEN:
			if bullets_taken >= ZombieDiceSettings.lose_condition_count:
				game_lost.emit()
	
	# determine if 3 bullets were fired and cancel round
	if pending_bullets >= 3:
		_setup_next_round()
		hit_three_times.emit()
		injury_count += 1
		injury_label.text = "Injuries: " + str(injury_count)
		
		if ZombieDiceSettings.lose_condition == ZombieDiceSettings.ZombieDiceLoseCondition.INJURY_COUNT:
			if injury_count >= ZombieDiceSettings.lose_condition_count:
				game_lost.emit()

# refresh all active_humans, all actions, finalize pending brains as score
func _on_stop_button_pressed() -> void:
	# finalize pending
	score += pending_brains
	score_label.text = "Brains: " + str(score)
	
	if score >= ZombieDiceSettings.win_condition_brain_count and not endless_mode_enabled:
		game_won.emit()
		endless_button.visible = true
		stop_button.visible = false
		draw_button.visible = false
	elif ZombieDiceSettings.lose_condition != ZombieDiceSettings.ZombieDiceLoseCondition.NONE:
		print("Lose condition : " + str(ZombieDiceSettings.lose_condition))
		print("Lose threshold: " + str(ZombieDiceSettings.lose_condition_count))
		match ZombieDiceSettings.lose_condition:
			ZombieDiceSettings.ZombieDiceLoseCondition.ROUNDS_PASSED:
				if _round > ZombieDiceSettings.lose_condition_count:
					game_lost.emit()
	
	_setup_next_round()

func _cleanup_round() -> void:
	pending_brains = 0
	pending_bullets = 0
	pending_brains_label.text = "0"
	pending_bullets_label.text = "0"
	
	# refresh cards
	if active_humans != null and active_humans.size() > 0:
		human_deck.append_array(active_humans)
	active_humans = []
	active_actions = []

# keep the game going, disable win conditions
func _on_endless_button_pressed() -> void:
	endless_mode_enabled = true
	endless_button.visible = false
	stop_button.visible = true
	draw_button.visible = true
