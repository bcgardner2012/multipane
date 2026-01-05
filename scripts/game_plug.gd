extends Node
class_name GamePlug

@export var portrait: Portrait

func _get_suit_channel() -> int:
	return get_parent().suit_channel
