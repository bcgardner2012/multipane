extends Label
class_name GaugeLabel

@export var maxValue: int

signal gaugeValueChanged(value: int)

var currentValue: int
var hotlinkingIsOn: bool

func _ready() -> void:
	currentValue = maxValue
	text = str(currentValue) + "/" + str(maxValue)

func _on_gauge_slider_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Decrease value by 1
		currentValue = clampi(currentValue - 1, 0, maxValue)
		text = str(currentValue) + "/" + str(maxValue)
		if hotlinkingIsOn:
			gaugeValueChanged.emit(currentValue)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Increase value by 1
		currentValue = clampi(currentValue + 1, 0, maxValue)
		text = str(currentValue) + "/" + str(maxValue)
		if hotlinkingIsOn:
			gaugeValueChanged.emit(currentValue)


func _on_hotlinker_hotlink(isOn: bool) -> void:
	hotlinkingIsOn = isOn
	if isOn:
		gaugeValueChanged.emit(currentValue)
