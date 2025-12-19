extends TextureRect
class_name SimpleIndicator

func _turn_on() -> void:
	print("Turned on")
	visible = true

func _turn_off() -> void:
	visible = false
