extends OptionButton
class_name ScoundrelAISelector

@export var brains: Node


func _on_ai_player_tool_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		visible = !visible
		_populate()

func _populate() -> void:
	clear()
	add_item("")
	for brain in brains.get_children():
		add_item(brain.name)

# index will be off-by-one relative to desired brain
func _on_item_selected(index: int) -> void:
	if index == 0:
		# first is empty
		return
		
	brains.get_child(index - 1).activate()
	$RadioSoundPlayer.play()
	visible = false
