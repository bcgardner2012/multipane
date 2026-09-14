extends Node
class_name BeetleGamePlayer

signal disable_auto_click()

@export var bugs: Array[BeetleGameBug]

var _signals: BeetleGamePane

func _ready() -> void:
	_signals = get_parent()

func _on_d_6_left_clicked(_node: D6) -> void:
	for i in range(bugs.size()):
		var bug = bugs[i]
		var d6 = bug.get_child(bug.get_child_count()-1)
		var r = d6.roll()
		if bug.increment(r-1):
			_signals.part_added.emit(i)
		
		if bug.is_complete():
			disable_auto_click.emit()
			_signals.game_over.emit(i)
