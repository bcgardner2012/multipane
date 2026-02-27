extends Node
class_name OutrunGamePlayer

signal error_red_dead()
signal error_blue_dead()
signal game_over()

@export var red_dice_container: OutrunDiceContainer
@export var blue_dice_container: OutrunDiceContainer
@export var green_dice_container: OutrunDiceContainer

@export var done_rolling_button: Button
@export var continue_button: Button
@export var option_button: OptionButton

@export var red_man: Control
@export var blue_man: Control
@export var green_man: Control

@export var red_desperation_label: Label
@export var blue_desperation_label: Label
@export var green_desperation_label: Label

const HELP_RED_OPTION = 0
const SCREW_RED_OPTION = 1
const HELP_BLUE_OPTION = 2
const SCREW_BLUE_OPTION = 3

const TARGETS_AI = 0
const TARGETS_HUMAN = 1
const DOES_HELP = 0
const DOES_SCREW = 1

const RED = 0
const BLUE = 1
const GREEN = 2

# key: <red_target><red_action><blue_t><blue_a><green_choice>
# val: [red_delta, blue_delta, green_delta]
const action_permutations = {
	"00000" = [9, 6, 0], # AIs helped each other, human helped red
	"00001" = [3, 6, 0], # AIs helped each other, human screwed red
	"00002" = [6, 9, 0], # AIs helped each other, human helped blue
	"00003" = [6, 3, 0], # AIs helped each other, human screwed blue
	"00010" = [-3, 6, 0], # Red helps blue, blue screws red, green helps red
	"00011" = [-9, 6, 0], # Red helps blue, blue screws red, green screws red
	"00012" = [-6, 9, 0], # Red helps blue, blue screws red, green helps blue
	"00013" = [-6, 3, 0], # Red helps blue, blue screws red, green screws blue
	"00100" = [3, 3, 3], # Red helps blue, blue helps green, green helps red
	"00101" = [-3, 3, 3], # Red helps blue, blue helps green, green screws red
	"00102" = [0, 9, 6], # Red helps blue, blue helps green, green helps blue
	"00103" = [0, -3, 6], # Red helps blue, blue helps green, green screws blue
	"00110" = [3, 3, -3], # Red helps blue, blue screws green, green helps red
	"00111" = [-3, 3, -3], # Red helps blue, blue screws green, green screws red
	"00112" = [0, 9, -6], # Red helps blue, blue screws green, green helps blue
	"00113" = [0, -3, -6], # Red helps blue, blue screws green, green screws blue
	"01000" = [9, -6, 0], # Red screwed blue, blue helps red, green helps red 
	"01001" = [3, -6, 0], # Red screwed blue, blue helps red, green screws red 
	"01002" = [6, -3, 0], # Red screwed blue, blue helps red, green helps blue 
	"01003" = [6, -9, 0], # Red screwed blue, blue helps red, green screws blue 
	"01010" = [-3, -6, 0], # AIs screwed each other, human helped red
	"01011" = [-9, -6, 0], # AIs screwed each other, human screwed red
	"01012" = [-6, -3, 0], # AIs screwed each other, human helped blue
	"01013" = [-6, -9, 0], # AIs screwed each other, human screwed blue
	"01100" = [3, -3, 3], # Red screwed blue, blue helps green, green helps red 
	"01101" = [-3, -3, 3], # Red screwed blue, blue helps green, green screws red 
	"01102" = [0, 3, 6], # Red screwed blue, blue helps green, green helps blue 
	"01103" = [0, -9, 6], # Red screwed blue, blue helps green, green screws blue
	"01110" = [3, -3, -3], # Red screwed blue, blue screwed green, green helps red 
	"01111" = [-3, -3, -3], # Red screwed blue, blue screwed green, green screws red 
	"01112" = [0, 3, -6], # Red screwed blue, blue screwed green, green helps blue 
	"01113" = [0, -9, -6], # Red screwed blue, blue screwed green, green screws blue 
	"10000" = [9, 0, 6], # Red helps green, blue helps red, green helps red
	"10001" = [-3, 0, 6], # Red helps green, blue helps red, green screws red
	"10002" = [3, 3, 3], # Red helps green, blue helps red, green helps blue
	"10003" = [3, -3, 3], # Red helps green, blue helps red, green screws blue
	"10010" = [3, 0, 6], # Red helps green, blue screws red, green helps red
	"10011" = [-9, 0, 6], # Red helps green, blue screws red, green screws red
	"10012" = [-3, 3, 3], # Red helps green, blue screws red, green helps blue
	"10013" = [-3, -3, 3], # Red helps green, blue screws red, green screws blue
	"10100" = [6, 0, 9], # Red helps green, blue helps green, green helps red
	"10101" = [-6, 0, 9], # Red helps green, blue helps green, green screws red
	"10102" = [0, 6, 9], # Red helps green, blue helps green, green helps blue
	"10103" = [0, -6, 9], # Red helps green, blue helps green, green screws blue
	"10110" = [6, 0, 3], # Red helps green, blue screws green, green helps red
	"10111" = [-6, 0, 3], # Red helps green, blue screws green, green screws red
	"10112" = [0, 6, -3], # Red helps green, blue screws green, green helps blue
	"10113" = [0, -6, -3], # Red helps green, blue screws green, green screws blue
	"11000" = [9, 0, -6], # Red screws green, blue helps red, green helps red
	"11001" = [-3, 0, -6], # Red screws green, blue helps red, green screws red
	"11002" = [3, 3, -3], # Red screws green, blue helps red, green helps blue
	"11003" = [3, -3, -3], # Red screws green, blue helps red, green screws blue
	"11010" = [3, 0, -6], # Red screws green, blue screws red, green helps red
	"11011" = [-9, 0, -6], # Red screws green, blue screws red, green screws red
	"11012" = [-3, 3, -3], # Red screws green, blue screws red, green helps blue
	"11013" = [-3, -3, -3], # Red screws green, blue screws red, green screws blue
	"11100" = [6, 0, -3], # Red screws green, blue helps green, green helps red
	"11101" = [-6, 0, -3], # Red screws green, blue helps green, green screws red
	"11102" = [0, 6, 3], # Red screws green, blue helps green, green helps blue
	"11103" = [0, -6, 3], # Red screws green, blue helps green, green screws blue
	"11110" = [6, 0, -9], # Red screws green, blue screws green, green helps red
	"11111" = [-6, 0, -9], # Red screws green, blue screws green, green screws red
	"11112" = [0, 6, -9], # Red screws green, blue screws green, green helps blue
	"11113" = [0, -6, -9], # Red screws green, blue screws green, green screws blue
}

var red_decision_texts = {
	"00" = "Helped Blue",
	"01" = "Screwed Blue",
	"10" = "Helped Green",
	"11" = "Screwed Green"
}

var blue_decision_texts = {
	"00" = "Helped Red",
	"01" = "Screwed Red",
	"10" = "Helped Green",
	"11" = "Screwed Green"
}

var _game_started: bool

var red_total: int
var blue_total: int
var green_total: int # the human player is green

var red_desperation: int
var blue_desperation: int
var green_desperation: int

var green_choice: int

var _done_rolling: bool
var _signals: OutrunGamePane

# game started
func _on_bear_gui_input(event: InputEvent) -> void:
	if not _game_started and ClickHelper.is_left_click(event):
		_signals = get_parent()
		_signals.game_started.emit()
		_game_started = true
		red_dice_container.visible = true
		blue_dice_container.visible = true
		green_dice_container.visible = true
		_start_next_round()

func _start_next_round() -> void:
	red_total = red_dice_container.roll_all(false, red_desperation)
	blue_total = blue_dice_container.roll_all(false, blue_desperation)
	green_total = green_dice_container.roll_all(true, green_desperation)
	

# currently, only green is clickable
func _on_die_left_clicked(node: D6) -> void:
	# a roll of 1 locks the die
	if not _done_rolling and node.value != 1:
		green_total -= node.value
		green_total += node.roll()
		green_dice_container.set_total_label(green_total)

# proceed to next phase where AIs decide who to target and whether to screw
func _on_done_rolling_pressed() -> void:
	_done_rolling = true
	done_rolling_button.visible = false
	option_button.visible = true
	# await player's selection

# only possible after done is clicked
func _on_option_button_item_selected(index: int) -> void:
	if (index == HELP_RED_OPTION or index == SCREW_RED_OPTION) and not red_dice_container.visible:
		# error, red is not valid now
		error_red_dead.emit()
		return
	elif (index == HELP_BLUE_OPTION or index == SCREW_BLUE_OPTION) and not blue_dice_container.visible:
		# error, blue is not valid now
		error_blue_dead.emit()
		return 
	
	option_button.visible = false
	continue_button.visible = true
	
	# decide what the AI do and update their labels
	var red_target = _determine_targeting(blue_dice_container)
	var red_action = _determine_action(blue_dice_container)
	
	var blue_target = _determine_targeting(red_dice_container)
	var blue_action = _determine_action(red_dice_container)
	
	var red_seq = str(red_target) + str(red_action)
	var blue_seq = str(blue_target) + str(blue_action)
	
	var key = red_seq + blue_seq + str(index)
	var deltas = action_permutations[key]
	red_total += deltas[0]
	blue_total += deltas[1]
	green_total += deltas[2]
	
	red_dice_container.set_total_label(red_total)
	red_dice_container.set_decision_label(red_decision_texts[red_seq])
	blue_dice_container.set_total_label(blue_total)
	blue_dice_container.set_decision_label(blue_decision_texts[blue_seq])
	green_dice_container.set_total_label(green_total)

func _determine_targeting(other_ai: OutrunDiceContainer) -> int:
	if other_ai.visible and green_dice_container.visible:
		return randi() % 2
	elif other_ai.visible and not green_dice_container.visible:
		return TARGETS_AI # can only target AI because human died
	elif not other_ai.visible and green_dice_container.visible:
		return TARGETS_HUMAN
	
	# shouldnt happen
	return 0

func _determine_action(other_ai: OutrunDiceContainer) -> int:
	if other_ai.visible:
		return randi() % 2
	else:
		return DOES_SCREW # no point in helping the one guy left

func _on_continue_pressed() -> void:
	continue_button.visible = false
	done_rolling_button.visible = true
	_done_rolling = false
	red_dice_container.set_decision_label("")
	blue_dice_container.set_decision_label("")
	
	# evaluate totals and refresh data
	if red_total < blue_total and red_total < green_total:
		if red_dice_container.lose_die() <= 0:
			red_dice_container.visible = false
			red_man.visible = false
			_signals.captured.emit(RED)
		else:
			_signals.attacked.emit(RED)
	elif blue_total < red_total and blue_total < green_total:
		if blue_dice_container.lose_die() <= 0:
			blue_dice_container.visible = false
			blue_man.visible = false
			_signals.attacked.emit(BLUE)
		else:
			_signals.captured.emit(BLUE)
	elif green_total < red_total and green_total < blue_total:
		if green_dice_container.lose_die() <= 0:
			green_dice_container.visible = false # player lost, soft lock
			green_man.visible = false
			game_over.emit()
			_signals.captured.emit(GREEN)
		else:
			_signals.captured.emit(GREEN)
	# else, there was a tie for last, no one loses anything
	_increment_desperation()
	_start_next_round()
	

func _increment_desperation() -> void:
	if red_total > blue_total:
		blue_desperation += 1
	if red_total > green_total:
		green_desperation += 1
	if blue_total > red_total:
		red_desperation += 1
	if blue_total > green_total:
		green_desperation += 1
	if green_total > red_total:
		red_desperation += 1
	if green_total > blue_total:
		blue_desperation += 1
		
	red_desperation_label.text = "!!! " + str(red_desperation) + " !!!"
	blue_desperation_label.text = "!!! " + str(blue_desperation) + " !!!"
	green_desperation_label.text = "!!! " + str(green_desperation) + " !!!"
