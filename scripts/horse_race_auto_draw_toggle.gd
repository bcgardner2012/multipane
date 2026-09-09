extends CheckButton
class_name HorseRaceAutoDrawToggle

# button_pressed true means the toggle is on

const DELAY = 1.0 # seconds

@export var deck: Deck

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
			deck._on_gui_input(_mock_mouse_event)
