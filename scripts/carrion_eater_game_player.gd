extends Node
class_name CarrionEaterGamePlayer

# Notes: this game can have a 100% win rate. Nothing forces the player out of
# the sky. Meaning they can skip any turns where they can only select 1 or 2, or
# burn them flying around, in order to only take turns where they can safely
# descend, attack, and ascend. And when you only have 6 health, why would you
# risk attacking 3-5 enemies with no escape? This makes the game feel incomplete

# Ideas: hard mode - players must burn all action points before ending turn
# (can force the player to allow enemies to heal / respawn), and triples knock
# the player out of the sky and force a turn skip (a triple alone isn't scary,
# but a triple followed by any sixes will force the player to take damage)

# AI Mode: the game has 0 real strategy, write an AI that plays it. Stays high,
# skips turns with only 1 or 2 rolls. Works from edge inward.

# Enemies are spread out: if enemies have 1 tile of space between them, the
# player can only ever cover 3 at a time, 2 if going for edges first. This makes
# respawning more likely from duplicates... also slows the game down with more
# move actions...

# Stamina die: every turn ended while ascended drains 1 stamina, forcing a landing
# every so often. This would result in players rushing to the edge of the map on
# the last turn to mitigate damage. Also makes it possible to create a safehouse
# when working from the edge inward.

# Bigger Health die: doesn't make the game any more strategic, but may encourage
# riskier play since attacks aren't so punishing, you'll see more scenes where
# the player is attacking AND being attacked. They'll use health to save time.

# More health, plus stamina die, plus triple-effects sounds like a fun combo.
# Spreading enemies out consumes more real-estate and slows down the game. Forcing
# the player to burn all action points feels pointless when there's a way to
# force them down to take damage. All-in-all, adds a chance mechanic that can
# actually make the player lose while keeping the idea that the player ought to
# maximize coverage and keep all enemies below full health. There's kind of a 
# dynamic timer on gameplay.

signal multiple_dice_rolled()
signal player_won()
signal player_lost()

@export var enemy_dice_node: CarrionEaterEnemyDice
@export var action_dice_node: CarrionEaterActionDice
@export var health_die: D6
@export var stamina_die: D6
@export var board: Control
@export var settings: CarrionEaterSettings

const X_MOTION_DELTA = 52 # pixels, enemy dice are this far apart
const Y_MOTION_DELTA = 104 # pixels, difference between ascend/descend poses
const HEALING_MAP = [0, -1, 1, -2, 2] # offsets of center based on die roll
var _y_motion_delta = Vector2(0, Y_MOTION_DELTA)
var _x_motion_delta = Vector2(X_MOTION_DELTA, 0)

var _game_started: bool
var _remaining_actions: int = 0 # max 5
var _action_die: D6
var _original_action_die_value: int
var _duplicates: Array[int] = []
var _rolls: Array[int] = []

var _is_ascended: bool = true
var _center_enemy_index: int = 2 # start at 2nd child of the enemy dice node

var _signals: CarrionEaterGamePane

func _physics_process(_delta) -> void:
	if not _game_started:
		return
	
	# enter key, reroll action dice
	# re-rolling should always be possible
	# the rules say nothing about when you can end your turn and start the next
	if Input.is_action_just_pressed("roll") and action_dice_node.count <= 5:
		_change_stamina()
		
		if _rolls.size() > 1:
			for die in _rolls:
				if _die_unused(die):
					var heal_index = _center_enemy_index + HEALING_MAP[die - 1]
					enemy_dice_node.heal(heal_index)
		
		_duplicates = []
		_rolls = action_dice_node.roll_dice()
		if action_dice_node.count == 1:
			_original_action_die_value = _action_die.value
			if not _action_die.value == 6:
				_remaining_actions = _action_die.value
			else:
				_remaining_actions = 0
		else:
			_remaining_actions = 0
			action_dice_node.awaiting_selection = true
			multiple_dice_rolled.emit()
	
	if _remaining_actions <= 0:
		return
	
	# arrow key up, ascend
	if Input.is_action_just_pressed("move_up") and not _is_ascended:
		board.position -= _y_motion_delta
		_is_ascended = true
		_decrement_remaining_actions()
		_signals.player_moved.emit()
	
	# arrow key down, descend
	if Input.is_action_just_pressed("move_down") and _is_ascended:
		board.position += _y_motion_delta
		_is_ascended = false
		_decrement_remaining_actions()
		_signals.player_moved.emit()
	
	# arrow key left, move left (nothing says the player can't move beyond the enemies...)
	if Input.is_action_just_pressed("move_left") and _center_enemy_index > 0:
		board.position -= _x_motion_delta
		_center_enemy_index -= 1
		_decrement_remaining_actions()
		_signals.player_moved.emit()
	
	# arrow key right, move right
	if Input.is_action_just_pressed("move_right") and _center_enemy_index < 4:
		board.position += _x_motion_delta
		_center_enemy_index += 1
		_decrement_remaining_actions()
		_signals.player_moved.emit()
	
	# space bar, attack enemy at slot 1
	if Input.is_action_just_pressed("attack") and not _is_ascended:
		_do_attack()
		_decrement_remaining_actions()

# not part of the original game rules, toggled via a setting
# do this before rolling dice so player could take damage from falling
func _change_stamina() -> void:
	if settings.is_stamina_enabled:
		if _is_ascended:
			if stamina_die.value == 1:
				board.position += _y_motion_delta
				_is_ascended = false
				stamina_die.set_value(6)
				_signals.player_fell.emit()
			else:
				stamina_die.decrement()
		else:
			stamina_die.set_value(6)

func _die_unused(die: int) -> bool:
	return not IntArrayHelper.contains(_duplicates, die) and die != 6 and _original_action_die_value != die

func _decrement_remaining_actions() -> void:
	_remaining_actions -= 1
	if _remaining_actions < 1:
		_action_die.visible = false
	else:
		_action_die.set_value(_remaining_actions)

func _do_attack() -> void:
	var result = enemy_dice_node.take_damage(_center_enemy_index)
	if result == -1:
		pass # TODO: error message?
	elif result == 1:
		action_dice_node.add_die()
		if enemy_dice_node.won():
			player_won.emit()
			_signals.player_won.emit()
	else:
		_signals.player_attacked.emit()

func _on_board_gui_input(event: InputEvent) -> void:
	if not _game_started and ClickHelper.is_left_click(event):
		_game_started = true
		_signals = get_parent()
		_init_dice()

func _init_dice() -> void:
	enemy_dice_node.init_dice()
	health_die.visible = true
	health_die.set_value(6)
	action_dice_node.roll_dice()
	_action_die = action_dice_node.action_die
	_remaining_actions = _action_die.value
	
	if settings.is_stamina_enabled:
		stamina_die.visible = true
		stamina_die.set_value(6)


func _on_action_dice_six_rolled() -> void:
	if not _is_ascended:
		var delta = 0
		for i in range(maxi(_center_enemy_index - 2, 0), mini(_center_enemy_index + 3, 5)):
			if enemy_dice_node.get_child(i).visible:
				delta += 1
		
		print(str(delta))
		if delta >= health_die.value:
			# game over
			print("Game Over")
			player_lost.emit()
			_signals.player_killed.emit()
		else:
			health_die.set_value(maxi(health_die.value - delta, 1))
			_signals.player_damaged.emit(health_die.value)

# Note: my take on the rules was that _size == health on respawn
func _on_action_dice_duplicates_rolled(duplicates: Array[int]) -> void:
	_duplicates = duplicates
	
	var uncovered: Array[int] = [0, 1, 2, 3, 4]
	var covered = range(maxi(_center_enemy_index - 2, 0), mini(_center_enemy_index + 3, 5))
	IntArrayHelper.remove_range(uncovered, covered)
	
	for u in uncovered:
		var die = enemy_dice_node.get_child(u) as D6
		if die.visible and die.value == 6:
			enemy_dice_node.respawn(duplicates.size()) 
			_signals.enemy_respawned.emit()
			# lose action die (it won't show properly until next round, 
			# but that's better because now the player can see why a die 
			# isn't clickable)
			action_dice_node.remove_die()
		elif die.visible:
			die.increment()
			_signals.enemy_healed.emit()


func _on_action_dice_action_die_selected() -> void:
	_remaining_actions = _action_die.value
	_original_action_die_value = _action_die.value

# enemy dice node already respawns, it just wants us to remove action die
func _on_enemy_dice_do_respawn() -> void:
	action_dice_node.remove_die()
	_signals.enemy_respawned.emit()
