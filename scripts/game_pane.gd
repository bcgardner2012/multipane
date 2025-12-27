extends Control
class_name GamePane

func _on_close_tool_gui_input(event: InputEvent) -> void:
	# close tool clicked, destroy pane
	if ClickHelper.is_left_click(event):
		queue_free()

# get image pane siblings and attempt to hook up my signals to them
# health_changed should broadcast to all health bars
# maybe we should have ScoundrelAdapters that are pre-configured to hook up certain
# signals and not others...
# The main function is updating the portrait node in response to a signal
func _on_broadcast_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		for sibling in get_parent().get_children():
			if sibling.has_method("receive_broadcast"):
				sibling.receive_broadcast(self)
