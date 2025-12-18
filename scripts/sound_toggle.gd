extends TextureRect
class_name SoundToggle

@export var sound_on_texture: Texture2D
@export var sound_off_texture: Texture2D

var isOn: bool

func _ready() -> void:
	isOn = true

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		isOn = !isOn
		if isOn:
			texture = sound_on_texture
		else:
			texture = sound_off_texture
