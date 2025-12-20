extends TextureRect
class_name SuitIcon

@export var clubTexture: Texture2D
@export var spadeTexture: Texture2D
@export var heartTexture: Texture2D
@export var diamondTexture: Texture2D

var index: int
var textures: Array[Texture2D]

func _ready() -> void:
	textures = []
	textures.append(clubTexture)
	textures.append(spadeTexture)
	textures.append(heartTexture)
	textures.append(diamondTexture)
	index = 0

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		index += 1
		index %= 4
		texture = textures[index]


func _on_suit_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		visible = !visible
