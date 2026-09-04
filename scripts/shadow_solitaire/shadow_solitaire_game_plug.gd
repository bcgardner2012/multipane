extends GamePlug
class_name ShadowSolitaireGamePlug

# 2 modes I can imagine here.
# Boss focus mode: when a round starts, record new boss, show defeat image for last
# and show profile for the next boss the first time the player attacks, HP reactive.
# Batman focus mode: health updates on round start, use scoundrel rules to show
# the player at x health. Attacks could have batman v goon imagery. Could alternate
# attacking goons and the boss, then #goons kinda equals boss health.

const BOSS_MODE = 0
const BATMAN_MODE = 1

const PLAYER_DIR = "player"
const ATTACK_DIR = "player/attack"
const BOMB_DIR = "player/bomb"
const GRAPPLE_DIR = "player/grapple"
const WON_DIR = "player/won"
const LOST_DIR = "player/lost"

# health can ACTUALLY range from -4 (2 jokers, shuffle, 2 more jokers) to 6
# (2 jokers immediately, or last boss). So, just provide imgs 0-4, seeburg
# is used, only last boss reliably uses more than that.
const INIT_BOSS_HP = 4

var prev_boss: CardData
var boss_str: String
var boss_health: int = INIT_BOSS_HP # possibly negative with efficient play

func on_player_won() -> void:
	if _get_suit_channel() == BATMAN_MODE:
		portrait.try_load_random_image_from_subdir(WON_DIR)

# Health checks are in "round_started" functionality
# Impossible to die before the first Queen is played, prev_boss will exist
func on_player_died() -> void:
	pass # see note above

func on_bomb_used(_target: CardData) -> void:
	boss_health -= 1
	if _get_suit_channel() == BATMAN_MODE:
		if not portrait.try_load_random_image_from_subdir(BOMB_DIR.path_join(boss_str)):
			if not portrait.try_load_random_image_from_subdir(BOMB_DIR):
				_show_attack_image()
	else:
		_show_boss_hp_img()

func on_new_round_started(boss: CardData, health: int) -> void:
	boss_health = INIT_BOSS_HP
	if _get_suit_channel() == BOSS_MODE:
		if prev_boss != null:
			var dir = boss_str.path_join("defeat")
			portrait.try_load_random_image_from_subdir(dir)
	else:
		if health <= 0:
			if not portrait.try_load_random_image_from_subdir(LOST_DIR.path_join(boss_str)):
				portrait.try_load_random_image_from_subdir(LOST_DIR)
		else:
			# cycle up from current hp to max looking for next valid image
			PortraitHelper.seeburg_select(portrait, health, 21)
	
	prev_boss = boss
	boss_str = _card_to_notation(boss)

# the point here is to reset the boss' image to show the new one, so we can
# also see the defeat scene for the last boss, briefly. Maybe we have a case for
# goon specific logic to though?
func on_attacked(_target: CardData, _action: CardData, healths: Array[int]) -> void:
	boss_health = _count_positive(healths) # possible off by 1, best we can do
	if _get_suit_channel() == BOSS_MODE:
		_show_boss_hp_img()
	else:
		_show_attack_image()

func on_grapple_attacked(_targets: Array[CardData], _action: CardData) -> void:
	boss_health -= 2
	if _get_suit_channel() == BATMAN_MODE:
		if not portrait.try_load_random_image_from_subdir(GRAPPLE_DIR.path_join(boss_str)):
			if not portrait.try_load_random_image_from_subdir(GRAPPLE_DIR):
				_show_attack_image()
	else:
		_show_boss_hp_img()

# could represent a minion being summoned
func on_joker_drawn() -> void:
	if _get_suit_channel() == BOSS_MODE:
		var dir = boss_str.path_join("summon")
		portrait.try_load_random_image_from_subdir(dir)

# special attacks will fallback to this too
func _show_attack_image() -> void:
	# boss specific first
	if not portrait.try_load_random_image_from_subdir(ATTACK_DIR.path_join(boss_str)):
		# failed to load boss specific image, fallback to generics
		portrait.try_load_random_image_from_subdir(ATTACK_DIR)

# shows boss profile, varies with hp / goon count
func _show_boss_hp_img() -> void:
	var profile_dir = boss_str.path_join("profile")
	# boss health == # alive goons
	PortraitHelper.seeburg_select_subdir(\
		portrait, \
		boss_health, \
		7, \
		profile_dir \
	)

func _count_positive(arr: Array[int]) -> int:
	var c = 0
	for x in arr:
		if x > 0:
			c += 1
	return c
