extends Control
class_name WarningsHolder

const WARNING_TTL = 3.0
var _timer: float
var warning_displayed: bool
var _ttl: float

func _process(delta: float) -> void:
	if warning_displayed:
		_timer += delta
		if _timer > _ttl:
			_timer = 0.0
			_hide_all_children()
			warning_displayed = false

func _hide_all_children() -> void:
	for child in get_children():
		child.visible = false

# subclasses should use this only
func _show_warning(node: Node, ttl: float = WARNING_TTL) -> void:
	_timer = 0.0
	_ttl = ttl
	_hide_all_children()
	node.visible = true
	warning_displayed = true

# intended for public consumption
func hide_all() -> void:
	warning_displayed = false
	_ttl = WARNING_TTL
	_timer = 0.0
	_hide_all_children()
