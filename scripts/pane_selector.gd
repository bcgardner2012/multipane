extends OptionButton
class_name PaneSelector

# Will appear as a grandchild of the Panes holder

const IMAGE_PANE = 0
const SCOUNDREL_GAME = 1
const AREA_52_GAME = 2
const SANDWICH_GUY_GAME = 3
const EMISSARY_GAME = 4
const WAR_GAME = 5
const HILO_GAME = 6
const BNN_GAME = 7
const ZOMBIE_DICE_GAME = 8
const JOKER_JB_GAME = 9
const SCORPION_TAIL_GAME = 10
const OUTLAW_GAME = 11
const CARD_CAPTURE_GAME = 12
const OUTRUN_GAME = 13
const SNAKE_CHARMER_GAME = 14
const CARRION_EATER_GAME = 15
const SS_GAME = 16
const CLUB_FIGHT_GAME = 17
const HORSE_RACE_GAME = 18
const BEETLE_GAME = 19
const THUNDERCLOUD_GAME = 20
const DICE_FISHING_GAME = 21
const HAUNTED_HOUSE_GAME = 22

func _on_item_selected(index: int) -> void:
	var panes_node = get_parent().get_parent()
	match index:
		IMAGE_PANE:
			panes_node.queue_add_image_pane()
		SCOUNDREL_GAME:
			panes_node.queue_add_scoundrel_game_pane()
		AREA_52_GAME:
			panes_node.queue_add_area_52_game_pane()
		SANDWICH_GUY_GAME:
			panes_node.queue_add_sandwich_guy_game_pane()
		EMISSARY_GAME:
			panes_node.queue_add_emissary_game_pane()
		WAR_GAME:
			panes_node.queue_add_war_game_pane()
		HILO_GAME:
			panes_node.queue_add_high_low_game_pane()
		BNN_GAME:
			panes_node.queue_add_bnn_game_pane()
		ZOMBIE_DICE_GAME:
			panes_node.queue_add_zombie_dice_game_pane()
		JOKER_JB_GAME:
			panes_node.queue_add_joker_jb_game_pane()
		SCORPION_TAIL_GAME:
			panes_node.queue_add_scorpion_tail_game_pane()
		OUTLAW_GAME:
			panes_node.queue_add_outlaw_game_pane()
		CARD_CAPTURE_GAME:
			panes_node.queue_add_card_capture_game_pane()
		OUTRUN_GAME:
			panes_node.queue_add_outrun_game_pane()
		SNAKE_CHARMER_GAME:
			panes_node.queue_add_snake_charmer_game_pane()
		CARRION_EATER_GAME:
			panes_node.queue_add_carrion_eater_game_pane()
		SS_GAME:
			panes_node.queue_add_ss_game_pane()
		CLUB_FIGHT_GAME:
			panes_node.queue_add_club_fight_game_pane()
		HORSE_RACE_GAME:
			panes_node.queue_add_horse_race_game_pane()
		BEETLE_GAME:
			panes_node.queue_add_beetle_game_pane()
		THUNDERCLOUD_GAME:
			panes_node.queue_add_thundercloud_game_pane()
		DICE_FISHING_GAME:
			panes_node.queue_add_dice_fishing_game_pane()
		HAUNTED_HOUSE_GAME:
			panes_node.queue_add_haunted_house_game_pane()
	
	if index >= 0:
		get_parent().free()
