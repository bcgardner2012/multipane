extends ColorRect
class_name GaugeSlider

@export var gaugeFill: ColorRect
@export var maxValue: int

# Currently assuming a max value of 20 is hardcoded
var currentValue: int

func _ready() -> void:
	currentValue = maxValue

func _on_gauge_slider_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		visible = !visible


func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		# Decrease value by 1
		currentValue = clampi(currentValue - 1, 0, maxValue)
		gaugeFill.anchor_right = (1.0 / maxValue) * currentValue
	elif ClickHelper.is_right_click(event):
		# Increase value by 1
		currentValue = clampi(currentValue + 1, 0, maxValue)
		gaugeFill.anchor_right = (1.0 / maxValue) * currentValue

func change_value(delta: int) -> int:
	currentValue = clampi(currentValue + delta, 0, maxValue)
	gaugeFill.anchor_right = (1.0 / maxValue) * currentValue
	$GaugeIcon/Label.update_text(str(currentValue))
	return currentValue
