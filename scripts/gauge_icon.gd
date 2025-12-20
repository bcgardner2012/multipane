extends TextureRect
class_name GaugeIcon

@export var healthTexture: Texture2D
@export var staminaTexture: Texture2D
@export var manaTexture: Texture2D

@export var healthColor: Color
@export var staminaColor: Color
@export var manaColor: Color

@export var gaugeFill: ColorRect

var index: int
var textures: Array[Texture2D]
var colors: Array[Color]

func _ready() -> void:
	textures = []
	textures.append(healthTexture)
	textures.append(staminaTexture)
	textures.append(manaTexture)
	colors.append(healthColor)
	colors.append(staminaColor)
	colors.append(manaColor)
	index = 0


func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		index += 1
		index %= 3
		texture = textures[index]
		gaugeFill.color = colors[index]
