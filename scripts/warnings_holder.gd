extends Control
class_name WarningsHolder

const WARNING_TTL = 3.0
var _timer: float
var warning_displayed: bool

func _process(delta: float) -> void:
	if warning_displayed:
		_timer += delta
		if _timer > WARNING_TTL:
			_timer = 0.0
			_hide_all_children()
			warning_displayed = false

func _hide_all_children() -> void:
	for child in get_children():
		child.visible = false

# subclasses should use this only
func _show_warning(node: Node) -> void:
	_hide_all_children()
	node.visible = true
	warning_displayed = true
