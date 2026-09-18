extends Control
class_name DiceFishingTripleCollider

# holds the texture of the intended fish caught during a triple roll.
# holds an index for corresponding data

signal caught(collider: DiceFishingTripleCollider, hole_number: int, is_big: bool)

@export var textureRect: TextureRect
@export var hole_number: int
@export var is_big: bool


func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		caught.emit(self, hole_number, is_big)
