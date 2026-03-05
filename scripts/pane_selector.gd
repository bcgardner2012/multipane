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
const JOKER_JB_GAME := 9
const SCORPION_TAIL_GAME := 10
const OUTLAW_GAME := 11
const CARD_CAPTURE_GAME := 12
const OUTRUN_GAME := 13
const SNAKE_CHARMER_GAME := 14

func _on_item_selected(index: int) -> void:
	var panes_node = get_parent().get_parent()
	if index == IMAGE_PANE:
		panes_node.queue_add_image_pane()
	elif index == SCOUNDREL_GAME:
		panes_node.queue_add_scoundrel_game_pane()
	elif index == AREA_52_GAME:
		panes_node.queue_add_area_52_game_pane()
	elif index == SANDWICH_GUY_GAME:
		panes_node.queue_add_sandwich_guy_game_pane()
	elif index == EMISSARY_GAME:
		panes_node.queue_add_emissary_game_pane()
	elif index == WAR_GAME:
		panes_node.queue_add_war_game_pane()
	elif index == HILO_GAME:
		panes_node.queue_add_high_low_game_pane()
	elif index == BNN_GAME:
		panes_node.queue_add_bnn_game_pane()
	elif index == ZOMBIE_DICE_GAME:
		panes_node.queue_add_zombie_dice_game_pane()
	elif index == JOKER_JB_GAME:
		panes_node.queue_add_joker_jb_game_pane()
	elif index == SCORPION_TAIL_GAME:
		panes_node.queue_add_scorpion_tail_game_pane()
	elif index == OUTLAW_GAME:
		panes_node.queue_add_outlaw_game_pane()
	elif index == CARD_CAPTURE_GAME:
		panes_node.queue_add_card_capture_game_pane()
	elif index == OUTRUN_GAME:
		panes_node.queue_add_outrun_game_pane()
	elif index == SNAKE_CHARMER_GAME:
		panes_node.queue_add_snake_charmer_game_pane()
	
	if index >= 0:
		get_parent().free()
