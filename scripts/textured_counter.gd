extends TextureRect
class_name TexturedCounter

@export var textures: Array[Texture2D]

var count: int

func increment() -> void:
	count = mini(count + 1, textures.size() - 1)
	texture = textures[count]
