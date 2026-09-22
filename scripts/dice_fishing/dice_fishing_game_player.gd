extends Node
class_name DiceFishingGamePlayer

signal unused_triple_error()
signal game_over()
signal game_won()
signal disable_nudging()

@export var dice_node: DiceFishingDice
@export var awful_casts: TexturedCounter
@export var nudges: TexturedCounter
@export var hole1: Array[DiceFishingTripleCollider] # use collider only bc it knows corresponding texture
@export var hole2: Array[DiceFishingTripleCollider]
@export var hole3: Array[DiceFishingTripleCollider]
@export var hole4: Array[DiceFishingTripleCollider]
@export var hole5: Array[DiceFishingTripleCollider]
@export var hole6: Array[DiceFishingTripleCollider]

const MAX_NUDGES = 4

var dice: Array[int]
var counts: Array[int]
var holes: Array # Array[Array[collider]]

var catch_count: int

var triple_mode: bool # disable when a fish is selected

var _signals: DiceFishingGamePane

func _ready() -> void:
	_signals = get_parent()
	call_deferred("_set_holes")

func _set_holes() -> void:
	holes = [
		hole1, hole2, hole3, hole4, hole5, hole6
	]

func _on_cast_button_pressed() -> void:
	if triple_mode:
		# error, you rolled a triple, select a fish
		unused_triple_error.emit()
		return
	
	if dice != [] and _was_awful_cast():
		awful_casts.increment()
		if awful_casts.count >= 3:
			_signals.game_over.emit()
			game_over.emit()
			return
	
	elif counts.any(func(number): return number == 2):
		var caught = counts.find(1)
		if _do_catch(caught):
			return
	
	# edge case, a triple was not rolled, the player nudged into a triple
	elif counts.any(func(number): return number == 3):
		var caught = counts.find(3)
		if _do_catch(caught):
			return
	
	dice = dice_node.roll()
	_count_dice()
	
	# check for triples or doubles
	if counts.any(func(number): return number == 3):
		# Enable fish selection
		triple_mode = true
		dice = [] # don't allow nudging, don't process this roll on the next cast

func _count_dice() -> void:
	counts = [
		0,0,0,0,0,0
	]
	for d in dice:
		counts[d-1] += 1

func _was_awful_cast() -> bool:
	_count_dice() # the dice that the previous roll finished on
	for c in counts:
		if c >= 2:
			return false
	return true

# return true if should exit player initiated logic early
func _do_catch(caught: int) -> bool:
	var arr = holes[caught] as Array[DiceFishingTripleCollider]
	var collider = arr.pop_front()
	if collider != null:
		_signals.catch.emit(collider.textureRect.name)
		# we can use textureRect.name to denote which fish was caught
		collider.textureRect.queue_free()
		# queue_free? Then we'll have nulls/bad data in the array...
		collider.queue_free()
		catch_count += 1
		if catch_count == 12:
			game_won.emit()
			_signals.game_won.emit()
			return true
	return false

func _on_nudgable_die_nudged_up(success: bool, index: int) -> void:
	if _is_not_nudgable(success):
		return
	dice[index] += 1
	nudges.increment()
	if nudges.count >= MAX_NUDGES:
		disable_nudging.emit()
	# no need for checks, casting will perform checks


func _on_nudgable_die_nudged_down(success: bool, index: int) -> void:
	if _is_not_nudgable(success):
		return
	dice[index] -= 1
	nudges.increment()
	if nudges.count >= MAX_NUDGES:
		disable_nudging.emit()

func _is_not_nudgable(success: bool) -> bool:
	return not success or triple_mode or dice == [] or nudges.count >= MAX_NUDGES


func _on_fish_collider_caught(collider: DiceFishingTripleCollider, hole_number: int, is_big: bool) -> void:
	if triple_mode:
		triple_mode = false
		_signals.catch.emit(collider.textureRect.name)
		collider.textureRect.queue_free()
		collider.queue_free()
		var hole = holes[hole_number] as Array[DiceFishingTripleCollider]
		if hole.size() >= 2 and is_big:
			hole.remove_at(1)
		elif hole.size() == 1:
			hole.remove_at(0)
		else:
			print("This shouldn't have happened...")
		
		catch_count += 1
		if catch_count == 12:
			game_won.emit()
			_signals.game_won.emit()
