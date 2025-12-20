extends TextureRect
class_name Coin

@export var heads_texture: Texture2D
@export var tails_texture: Texture2D

var isMute: bool

func _ready() -> void:
	randomize()
	isMute = false

func _on_coin_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		visible = !visible


func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		if not isMute:
			$AudioStreamPlayer.play()
		var r = randi() %2
		if r == 0:
			texture = heads_texture
		else:
			texture = tails_texture


func _on_sound_toggle_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		isMute = !isMute
