extends GamePlug
class_name ShadowSolitaireGamePlug

# 2 modes I can imagine here.
# Boss focus mode: when a round starts, record new boss, show defeat image for last
# and show profile for next first time the player attacks
# Batman focus mode: health updates on round start, use scoundrel rules to show
# the player at x health

const BOSS_MODE = 0
const BATMAN_MODE = 1

var prev_boss: CardData

func on_player_won() -> void:
	if _get_suit_channel() == BATMAN_MODE:
		portrait.try_load_random_image_from_subdir("player_won")

# Health checks are in round started
func on_player_died() -> void:
	pass

func on_bomb_used() -> void:
	if _get_suit_channel() == BATMAN_MODE:
		portrait.try_load_random_image_from_subdir("bomb")

func on_new_round_started(boss: CardData, health: int) -> void:
	if _get_suit_channel() == BOSS_MODE:
		if prev_boss != null:
			var dir = _card_to_notation(prev_boss).path_join("defeat")
			portrait.try_load_random_image_from_subdir(dir)
			prev_boss = boss
	else:
		if health <= 0:
			portrait.try_load_random_image_from_subdir("player_died")
		else:
			# cycle up from current hp to max looking for next valid image
			PortraitHelper.seeburg_select(portrait, health, 21)

# the point here is to reset the boss' image to show the new one, so we can
# also see the defeat scene for the last boss, briefly. Maybe we have a case for
# goon specific logic to though?
func on_attacked(target: CardData, action: CardData) -> void:
	if _get_suit_channel() == BOSS_MODE:
		var dir = _card_to_notation(prev_boss).path_join("profile")
		portrait.try_load_random_image_from_subdir(dir)
