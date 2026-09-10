extends CheckButton
class_name AutoClickerToggle

# The given clickable_node must implement a _on_gui_input(InputEventMouseButton)
# function.
# button_pressed true means the toggle is on.

const DELAY = 1.0 # seconds

@export var clickable_node: Control

var _timer: float
var _mock_mouse_event: InputEventMouseButton

func _ready() -> void:
	_mock_mouse_event = InputEventMouseButton.new()
	_mock_mouse_event.button_index = MOUSE_BUTTON_LEFT
	_mock_mouse_event.pressed = true

func _process(delta: float) -> void:
	if button_pressed:
		_timer += delta
		if _timer >= DELAY:
			_timer = 0.0
			clickable_node._on_gui_input(_mock_mouse_event)

# connect signals to this to disable auto clicking
func _turn_off() -> void:
	button_pressed = false
