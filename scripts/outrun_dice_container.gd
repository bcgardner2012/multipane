extends Control
class_name OutrunDiceContainer

func roll_all(is_player: bool, desperation: int) -> int:
	var total = desperation
	for d in $HBoxContainer.get_children():
		var die = d as D6
		var r = die.roll()
		
		# AI Behavior to reroll based solely on individual values rolled
		if not is_player:
			# 2 is the only value with >50% odds of improving on reroll
			while r == 2:
				r = die.roll()
		
		total += r
	
	$Label.text = str(total)
	return total

func set_total_label(total: int) -> void:
	$Label.text = str(total)

func set_decision_label(text: String) -> void:
	$Decision.text = text

# returns number of dice left
func lose_die() -> int:
	var cc = $HBoxContainer.get_child_count()
	if cc > 0:
		$HBoxContainer.get_child(0).free()
	return cc - 1
