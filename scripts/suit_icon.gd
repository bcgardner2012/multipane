extends TextureRect
class_name SuitIcon

@export var clubTexture: Texture2D
@export var spadeTexture: Texture2D
@export var heartTexture: Texture2D
@export var diamondTexture: Texture2D

# 0 = hearts, 1 = diamonds, 2 = clubs, 3 = spades
signal tune_suit_channel(channel: int)

var index: int
var textures: Array[Texture2D]

func _ready() -> void:
	textures = []
	textures.append(heartTexture)
	textures.append(diamondTexture)
	textures.append(clubTexture)
	textures.append(spadeTexture)
	index = 0

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		index += 1
		index %= 4
		texture = textures[index]
		tune_suit_channel.emit(index)


func _on_suit_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		visible = !visible
		tune_suit_channel.emit(index)
