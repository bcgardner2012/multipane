extends Node
class_name OutlawGamePlayer

signal error_too_few_dice_claimed()
signal player_won()
signal player_lost()

@export var roll_area: OutlawRollArea
@export var keep_area: OutlawKeepArea
@export var keep_area_label: Label
@export var chart: OutlawChart
@export var score_label: Label
@export var npc_score_label: Label
@export var _signals: OutlawGamePane

const MAX_ROLL_COUNT: int = 3
const MAX_CLAIM_COUNT: int = 4
const CLAIM_INTERVAL: int = 3 # wipe marks after this many are accrued

var roll_count: int
var claimed_dice_count: int
var score: int
var npc_score: int

var _d6_init_count: int

func _ready() -> void:
	roll_count = 1

func _on_reroll_button_pressed() -> void:
	if (roll_count < MAX_ROLL_COUNT):
		roll_count += 1
		roll_area.reroll()
		if (roll_count == MAX_ROLL_COUNT):
			roll_area.move_dice_to_keep_area()
			claimed_dice_count = MAX_CLAIM_COUNT
			_update_total_label()

# the dice will tell us when they are ready. Init them with a random number.
func _on_d_6_d_6_entered_tree(node: D6) -> void:
	if (_d6_init_count < MAX_CLAIM_COUNT):
		node.roll()
		_d6_init_count += 1

# if parent of clicked die is RollArea, move to KeepArea
func _on_d_6_left_clicked(node: D6) -> void:
	if (node.get_parent() == roll_area):
		node.reparent(keep_area, false)
		claimed_dice_count += 1
		_update_total_label()

func _on_claim_button_pressed() -> void:
	if (claimed_dice_count >= MAX_CLAIM_COUNT):
		claimed_dice_count = 0
		var total = keep_area.get_dice_total()
		chart.mark(total, true)
		keep_area.move_dice_to_roll_area()
		_update_total_label()
		roll_area.reroll()
		roll_count = 1
		if chart.get_mark_count(OutlawCross.Owner.PLAYER) == CLAIM_INTERVAL:
			var delta = chart.get_score(OutlawCross.Owner.PLAYER)
			score += delta
			chart.clear(true)
			score_label.text = "Player Score: $" + str(score)
			if score >= 50000:
				player_won.emit()
				_signals.player_won.emit()
			else:
				_signals.bounty_collected.emit(delta, true)
		_do_npc_turn()
	else:
		error_too_few_dice_claimed.emit()

func _update_total_label() -> void:
	keep_area_label.text = "Total: " + str(keep_area.get_dice_total())

func _do_npc_turn() -> void:
	var dice: Array[int] = []
	for i in range(0, 6):
		dice.append((randi() % 6) + 1)
	
	# pick best unclaimed by AI permutation rolled (|r - 14| is the priority)
	var permuted_totals: Array[int] = []
	for a in range(0, 6):
		var die_a = dice[a]
		for b in range(a+1, 6):
			var die_b = dice[b]
			for c in range(b+1, 6):
				var die_c = dice[c]
				for d in range(c+1, 6):
					var die_d = dice[d]
					permuted_totals.append(die_a + die_b + die_c + die_d)
		
	var winner = 0
	var best_score = -1
	for pt in permuted_totals:
		var _score = abs(pt - 14)
		if _score > best_score and chart.who_owns(pt) != OutlawCross.Owner.NPC:
			best_score = _score
			winner = pt
	
	chart.mark(winner, false)
	if chart.get_mark_count(OutlawCross.Owner.NPC) == CLAIM_INTERVAL:
		var delta = chart.get_score(OutlawCross.Owner.NPC)
		npc_score += delta
		chart.clear(false)
		npc_score_label.text = "NPC Score: $" + str(npc_score)
		if npc_score >= 50000:
			player_lost.emit()
			_signals.player_lost.emit()
		else:
			_signals.bounty_collected.emit(delta, false)
