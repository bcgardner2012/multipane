extends Node
class_name SnakeCharmerGamePlayer

signal red_won()
signal blue_won()
signal green_won()

const RED = 0
const BLUE = 1
const GREEN = 2

@export var snake_die: D6
@export var red_die: D6
@export var blue_die: D6
@export var green_die: D6
@export var red_label: Label
@export var blue_label: Label
@export var green_label: Label
@export var red_man: Control
@export var blue_man: Control
@export var green_man: Control

var _game_started: bool

var red_hp: int = 3
var blue_hp: int = 3
var green_hp: int = 3

var snake_roll: int
var red_roll: int
var blue_roll: int
var green_roll: int

var red_active: bool = true
var blue_active: bool = true
var green_active: bool = true

var _timer: float
const TICK_RATE = 1.0 # seconds

var _signals: SnakeCharmerGamePane

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _game_started:
		_timer += delta
		if _timer >= TICK_RATE:
			_timer = 0.0
			_do_round()


func _on_snake_gui_input(event: InputEvent) -> void:
	if not _game_started and ClickHelper.is_left_click(event):
		_signals = get_parent()
		_game_started = true
		_reroll_all_dice()

func _reroll_all_dice() -> void:
	snake_die.visible = true
	if red_hp > 0:
		red_die.visible = true
		red_roll = red_die.roll()
	if blue_hp > 0:
		blue_die.visible = true
		blue_roll = blue_die.roll()
	if green_hp > 0:
		green_die.visible = true
		green_roll = green_die.roll()
	
	snake_roll = snake_die.roll()

func _do_round() -> void:
	# if only 1 is active, we are close to the snake. This roll determines win.
	if _only_red_active():
		if red_roll != snake_roll:
			red_active = false
			red_hp -= 1
			if red_hp <= 0:
				red_man.visible = false
				red_die.visible = false
				_signals.player_lost.emit(RED)
			else:
				_signals.player_bit.emit(RED)
		else:
			red_won.emit()
			_game_started = false
	elif _only_blue_active():
		if blue_roll != snake_roll:
			blue_active = false
			blue_hp -= 1
			if blue_hp <= 0:
				blue_man.visible = false
				blue_die.visible = false
				_signals.player_lost.emit(BLUE)
			else:
				_signals.player_bit.emit(BLUE)
		else:
			blue_won.emit()
			_game_started = false
	elif _only_green_active():
		if green_roll != snake_roll:
			green_active = false
			green_hp -= 1
			if green_hp <= 0:
				green_man.visible = false
				green_die.visible = false
				_signals.player_lost.emit(GREEN)
			else:
				_signals.player_bit.emit(GREEN)
		else:
			green_won.emit()
			_game_started = false
	else:
		if red_active and red_roll != snake_roll:
			red_active = false
			red_die.visible = false
			_signals.player_rolled.emit(RED)
		if blue_active and blue_roll != snake_roll:
			blue_active = false
			blue_die.visible = false
			_signals.player_rolled.emit(BLUE)
		if green_active and green_roll != snake_roll:
			green_active = false
			green_die.visible = false
			_signals.player_rolled.emit(GREEN)
			
		if _only_red_active():
			_signals.player_trying_to_capture.emit(RED)
		if _only_blue_active():
			_signals.player_trying_to_capture.emit(BLUE)
		if _only_green_active():
			_signals.player_trying_to_capture.emit(GREEN)
	
	# if only 1 alive, they win
	if _only_red_alive():
		red_won.emit()
		_signals.player_won.emit(RED)
		_game_started = false
	elif _only_blue_alive():
		blue_won.emit()
		_signals.player_won.emit(BLUE)
		_game_started = false
	elif _only_green_alive():
		green_won.emit()
		_signals.player_won.emit(GREEN)
		_game_started = false
	elif _all_inactive():
		_activate_all()
		_reroll_all_dice()
	else:
		_reroll_actives()
	
	_update_labels()
	
func _all_inactive() -> bool:
	return not red_active and not blue_active and not green_active

func _reroll_actives() -> void:
	if red_active:
		red_roll = red_die.roll()
	if blue_active:
		blue_roll = blue_die.roll()
	if green_active:
		green_roll = green_die.roll()

func _only_red_active() -> bool:
	return red_active and not blue_active and not green_active

func _only_blue_active() -> bool:
	return not red_active and blue_active and not green_active

func _only_green_active() -> bool:
	return not red_active and not blue_active and green_active 

func _update_labels() -> void:
	red_label.text = str(red_hp)
	blue_label.text = str(blue_hp)
	green_label.text = str(green_hp)

func _activate_all() -> void:
	if red_hp > 0:
		red_active = true
	if blue_hp > 0:
		blue_active = true
	if green_hp > 0:
		green_active = true

func _only_red_alive() -> bool:
	return red_hp > 0 and blue_hp <= 0 and green_hp <= 0

func _only_blue_alive() -> bool:
	return red_hp <= 0 and blue_hp > 0 and green_hp <= 0

func _only_green_alive() -> bool:
	return red_hp <= 0 and blue_hp <= 0 and green_hp > 0
