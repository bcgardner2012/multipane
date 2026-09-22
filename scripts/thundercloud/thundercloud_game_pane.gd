extends Control
class_name ThundercloudGamePane

signal game_over(winner: Color)
signal struck(color: Color) # the color of the player struck
signal not_struck(color: Color)


func _on_broadcast_tool_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_close_tool_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.
