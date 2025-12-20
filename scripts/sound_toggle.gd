extends TextureRect
class_name SoundToggle

@export var sound_on_texture: Texture2D
@export var sound_off_texture: Texture2D

var isOn: bool

func _ready() -> void:
	isOn = true

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		isOn = !isOn
		if isOn:
			texture = sound_on_texture
		else:
			texture = sound_off_texture
