extends OptionButton
class_name PaneSelector

# Will appear as a grandchild of the Panes holder

const IMAGE_PANE := 0
const SCOUNDREL_GAME := 1

func _on_item_selected(index: int) -> void:
	if index == IMAGE_PANE:
		get_parent().get_parent().queue_add_image_pane()
		get_parent().free()
	elif index == SCOUNDREL_GAME:
		pass
