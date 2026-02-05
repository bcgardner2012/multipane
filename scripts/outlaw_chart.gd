extends TextureRect
class_name OutlawChart

@export var _signals: OutlawGamePane

func clear(is_player_turn: bool) -> void:
	for child in get_children():
		var cross = child as OutlawCross
		if is_player_turn and cross.owning_player == OutlawCross.Owner.PLAYER:
			cross.clear()
		elif not is_player_turn and cross.owning_player == OutlawCross.Owner.NPC:
			cross.clear()

# only very specific sums are valid. They all also have a different monetary value
func mark(sum: int, is_player_turn: bool) -> void:
	var index = _compute_index(sum)
	if index != -1:
		var cross = get_child(index) as OutlawCross
		var prev_owner = cross.owning_player
		cross.capture(is_player_turn)
		var new_owner = cross.owning_player
		_signals.outlaw_claimed.emit(sum, new_owner, prev_owner)

func get_mark_count(owning_player: OutlawCross.Owner) -> int:
	var count = 0
	for child in get_children():
		var cross = child as OutlawCross
		if cross.owning_player == owning_player:
			count += 1
	return count

func get_score(owning_player: OutlawCross.Owner) -> int:
	var score = 0
	var index = 0
	for child in get_children():
		var cross = child as OutlawCross
		if cross.owning_player == owning_player:
			match index:
				0:
					score += 10000
				1:
					score += 7000
				2:
					score += 5000
				3:
					score += 3000
				4:
					score += 2000
				5:
					score += 1000
				6:
					score += 1000
				7:
					score += 2000
				8:
					score += 3000
				9:
					score += 5000
				10:
					score += 7000
				11:
					score += 10000
			
		index += 1
	return score

func who_owns(outlaw: int) -> OutlawCross.Owner:
	var index = _compute_index(outlaw)
	if index != -1:
		return (get_child(index) as OutlawCross).owning_player
	return OutlawCross.Owner.NONE

# -1 means sum has no corresponding ui element
func _compute_index(sum: int) -> int:
	if sum < 10:
		return sum - 4 # sum of 4 starts indexing at 0
	elif sum > 18:
		return sum - 13 # sum of 19 starts indexing at 6
	return -1
