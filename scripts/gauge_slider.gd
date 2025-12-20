extends ColorRect
class_name GaugeSlider

@export var gaugeFill: ColorRect
@export var maxValue: int

# Currently assuming a max value of 20 is hardcoded
var currentValue: int

func _ready() -> void:
	currentValue = maxValue

func _on_gauge_slider_tool_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		visible = !visible


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Decrease value by 1
		currentValue = clampi(currentValue - 1, 0, maxValue)
		gaugeFill.anchor_right = (1.0 / maxValue) * currentValue
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Increase value by 1
		currentValue = clampi(currentValue + 1, 0, maxValue)
		gaugeFill.anchor_right = (1.0 / maxValue) * currentValue

func change_value(delta: int) -> int:
	currentValue = clampi(currentValue + delta, 0, maxValue)
	gaugeFill.anchor_right = (1.0 / maxValue) * currentValue
	$GaugeIcon/Label.update_text(str(currentValue))
	return currentValue
