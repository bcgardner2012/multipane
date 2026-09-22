extends GamePlug
class_name HauntedHouseGamePlug

const MINION_DIR = "minion"
const REST_DIR = "rest"
const QUEEN_DIR = "queen"
const DEAD_DIR = "dead"
const TRAP_DIR = "trap"

func on_parrot_encounter(_defended: bool) -> void:
	if not portrait.try_load_random_image_from_subdir("parrot"):
		portrait.try_load_random_image_from_subdir(MINION_DIR)

func on_spider_encounter(_defended: bool) -> void:
	if not portrait.try_load_random_image_from_subdir("spider"):
		portrait.try_load_random_image_from_subdir(MINION_DIR)

func on_rat_encounter(_defended: bool) -> void:
	if not portrait.try_load_random_image_from_subdir("rat"):
		portrait.try_load_random_image_from_subdir(MINION_DIR)

func on_trap_encounter(_defended: bool, keyword: String) -> void:
	match keyword:
		"fall_trap":
			if not portrait.try_load_random_image_from_subdir(TRAP_DIR.path_join("fall")):
				portrait.try_load_random_image_from_subdir(TRAP_DIR)
		"claw_trap":
			if not portrait.try_load_random_image_from_subdir(TRAP_DIR.path_join("claw")):
				portrait.try_load_random_image_from_subdir(TRAP_DIR)
		"armor_trap":
			if not portrait.try_load_random_image_from_subdir(TRAP_DIR.path_join("armor")):
				portrait.try_load_random_image_from_subdir(TRAP_DIR)
		"skeleton_trap":
			if not portrait.try_load_random_image_from_subdir(TRAP_DIR.path_join("skeleton")):
				portrait.try_load_random_image_from_subdir(TRAP_DIR)
		"puppet_trap":
			if not portrait.try_load_random_image_from_subdir(TRAP_DIR.path_join("puppet")):
				portrait.try_load_random_image_from_subdir(TRAP_DIR)
		"deadend_trap":
			if not portrait.try_load_random_image_from_subdir(TRAP_DIR.path_join("deadend")):
				portrait.try_load_random_image_from_subdir(TRAP_DIR)

func on_ghost_encounter(_defended: bool) -> void:
	if _defended:
		if portrait.try_load_random_image_from_subdir("ghost".path_join("defended")):
			return
	
	if not portrait.try_load_random_image_from_subdir("ghost"):
		portrait.try_load_random_image_from_subdir(MINION_DIR)

# can't really be defended
func on_abomination_encounter(_defended: bool) -> void:
	if not portrait.try_load_random_image_from_subdir("abomination"):
		portrait.try_load_random_image_from_subdir(MINION_DIR)

func on_wild_potion() -> void:
	portrait.try_load_random_image_from_subdir("potion")

func on_wild_gargoyle() -> void:
	if not portrait.try_load_random_image_from_subdir("gargoyle"):
		portrait.try_load_random_image_from_subdir(MINION_DIR)

func on_wild_bat() -> void:
	if not portrait.try_load_random_image_from_subdir("bat"):
		portrait.try_load_random_image_from_subdir(MINION_DIR)

func on_ace_found() -> void:
	portrait.try_load_random_image_from_subdir("survivor")

func on_saferoom_reached() -> void:
	portrait.try_load_random_image_from_subdir("saferoom")

func on_saferoom_rest() -> void:
	portrait.try_load_random_image_from_subdir(REST_DIR)

func on_saferoom_meditate() -> void:
	if not portrait.try_load_random_image_from_subdir("meditate"):
		portrait.try_load_random_image_from_subdir(REST_DIR)

func on_saferoom_plead() -> void:
	if not portrait.try_load_random_image_from_subdir("plead"):
		portrait.try_load_random_image_from_subdir(REST_DIR)

func on_saferoom_search(_found: bool, _item: HauntedHouseGamePlayer.Item) -> void:
	if _found and _item == HauntedHouseGamePlayer.Item.DOLL:
		if not portrait.try_load_random_image_from_subdir("voodoo"):
			if not portrait.try_load_random_image_from_subdir("search"):
				portrait.try_load_random_image_from_subdir(REST_DIR)
	
	if not portrait.try_load_random_image_from_subdir("search"):
		portrait.try_load_random_image_from_subdir(REST_DIR)

func on_queen_spotted() -> void:
	portrait.try_load_random_image_from_subdir(QUEEN_DIR)

func on_queen_heal() -> void:
	if not portrait.try_load_random_image_from_subdir(QUEEN_DIR.path_join("heal")):
		portrait.try_load_random_image_from_subdir(QUEEN_DIR)

func on_queen_calm() -> void:
	if not portrait.try_load_random_image_from_subdir(QUEEN_DIR.path_join("heal")):
		portrait.try_load_random_image_from_subdir(QUEEN_DIR)

func on_queen_soothe() -> void:
	if not portrait.try_load_random_image_from_subdir(QUEEN_DIR.path_join("soothe")):
		portrait.try_load_random_image_from_subdir(QUEEN_DIR)

func on_queen_gift() -> void:
	if not portrait.try_load_random_image_from_subdir(QUEEN_DIR.path_join("gift")):
		portrait.try_load_random_image_from_subdir(QUEEN_DIR)

func on_game_over_dead() -> void:
	portrait.try_load_random_image_from_subdir(DEAD_DIR)

func on_game_over_cursed() -> void:
	if not portrait.try_load_random_image_from_subdir("cursed"):
		portrait.try_load_random_image_from_subdir(DEAD_DIR)

func on_game_over_angry() -> void:
	if not portrait.try_load_random_image_from_subdir("angry"):
		portrait.try_load_random_image_from_subdir(DEAD_DIR)

func on_game_won() -> void:
	portrait.try_load_random_image_from_subdir("win")
