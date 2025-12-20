extends TextureRect
class_name Hotlinker

@export var offTexture: Texture2D
@export var onTexture: Texture2D

signal hotlink(isOn: bool)

var isOn: bool


func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		isOn = !isOn
		if isOn:
			texture = onTexture
		else:
			texture = offTexture
		hotlink.emit(isOn)
