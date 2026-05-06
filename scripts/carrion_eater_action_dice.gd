extends Control
class_name CarrionEaterActionDice

# responds to clicks on the action dice. Will choose one of them as the
# active action die at the beginning of each round.

# upon selection, all but the first child should be hidden, its value set to
# the selected die.

# if there were any duplicates, that should be raised as a signal

@export var action_die: D6

signal six_rolled()
# count of unique numbers forming pairs+
signal duplicates_rolled(size: int)
signal action_die_selected()

var count: int = 1
# TODO: vv
var awaiting_selection: bool = false
var _duplicates: Array[int]

func add_die() -> void:
	count += 1

func remove_die() -> void:
	count -= 1

func roll_dice() -> Array[int]:
	visible = true
	
	_duplicates = []
	var seen_numbers: Array[int] = []
	var saw_six: bool = false
	for i in range(count):
		var die = get_child(i) as D6
		die.visible = true
		die.roll()
		if IntArrayHelper.contains(seen_numbers, die.value):
			_duplicates.append(die.value)
		seen_numbers.append(die.value)
		if die.value == 6:
			saw_six = true
	
	if saw_six:
		six_rolled.emit()
	if _duplicates.size() > 0:
		duplicates_rolled.emit(IntArrayHelper.dedupe(_duplicates))
	return seen_numbers

func _show_action_die_only() -> void:
	for child in get_children():
		var die = child as D6
		die.visible = false
	action_die.visible = true

# if its time to select an action die, then set child 0 and hide the rest
func _on_d_6_left_clicked(node: D6) -> void:
	# can't select sixes or dice used as part of a double+
	if awaiting_selection and not node.value == 6 and not IntArrayHelper.contains(_duplicates, node.value):
		awaiting_selection = false
		action_die.set_value(node.value)
		_show_action_die_only()
		action_die_selected.emit()
	else:
		if not awaiting_selection:
			print("Was not awaiting selection. Die click was ignored.")
		elif node.value == 6:
			print("Clicked die was a 6. Cannot use 6s.")
		elif IntArrayHelper.contains(_duplicates, node.value):
			print("Clicked die was part of a pair, cannot use.")
		else:
			print("This is a bug triggered when an action die was clicked")
