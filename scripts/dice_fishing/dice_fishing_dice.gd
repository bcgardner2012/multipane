extends HBoxContainer
class_name DiceFishingDice

func roll() -> Array[int]:
	var arr: Array[int] = []
	for child in get_children():
		var die = child as NudgableDie
		arr.append(die.roll())
	return arr
