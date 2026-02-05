extends GamePlug
class_name ScorpionTailGamePlug

const PLAYER_DIR = "player"
const NPC_DIR = "npc"

# show an image, 0-13 based on array size
func on_tail_grew(tail: Array[CardData]) -> void:
	PortraitHelper.seeburg_select(portrait, tail.size(), -1, -1)

# show an image, based mainly on was_player_stung, second by tail size
func on_tail_stung(tail: Array[CardData], was_player_stung: bool) -> void:
	if was_player_stung:
		PortraitHelper.seeburg_select_subdir(portrait, tail.size(), -1, PLAYER_DIR, -1)
	else:
		PortraitHelper.seeburg_select_subdir(portrait, tail.size(), -1, NPC_DIR, -1)
