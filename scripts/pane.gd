extends Control
class_name Pane


func _on_close_tool_gui_input(event: InputEvent) -> void:
	# close tool clicked, destroy pane
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		queue_free()
