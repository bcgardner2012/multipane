extends OptionButton
class_name PaneSelector

# Will appear as a grandchild of the Panes holder

const IMAGE_PANE := 0
const SCOUNDREL_GAME := 1
const AREA_52_GAME := 2
const SANDWICH_GUY_GAME := 3
const EMISSARY_GAME := 4
const WAR_GAME := 5
const HILO_GAME := 6
const BNN_GAME := 7
const ZOMBIE_DICE_GAME := 8

func _on_item_selected(index: int) -> void:
	if index == IMAGE_PANE:
		get_parent().get_parent().queue_add_image_pane()
		get_parent().free()
	elif index == SCOUNDREL_GAME:
		get_parent().get_parent().queue_add_scoundrel_game_pane()
		get_parent().free()
	elif index == AREA_52_GAME:
		get_parent().get_parent().queue_add_area_52_game_pane()
		get_parent().free()
	elif index == SANDWICH_GUY_GAME:
		get_parent().get_parent().queue_add_sandwich_guy_game_pane()
		get_parent().free()
	elif index == EMISSARY_GAME:
		get_parent().get_parent().queue_add_emissary_game_pane()
		get_parent().free()
	elif index == WAR_GAME:
		get_parent().get_parent().queue_add_war_game_pane()
		get_parent().free()
	elif index == HILO_GAME:
		get_parent().get_parent().queue_add_high_low_game_pane()
		get_parent().free()
	elif index == BNN_GAME:
		get_parent().get_parent().queue_add_bnn_game_pane()
		get_parent().free()
	elif index == ZOMBIE_DICE_GAME:
		get_parent().get_parent().queue_add_zombie_dice_game_pane()
		get_parent().free()
