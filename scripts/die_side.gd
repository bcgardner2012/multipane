extends Node
class_name DieSide

@export var sprites: Array[Texture2D]

func get_random_sprite() -> Texture2D:
	return sprites[randi() % sprites.size()]
