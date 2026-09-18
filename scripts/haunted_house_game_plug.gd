extends GamePlug
class_name HauntedHouseGamePlug

func on_parrot_encounter(defended: bool) -> void:
	pass

func on_spider_encounter(defended: bool) -> void:
	pass

func on_rat_encounter(defended: bool) -> void:
	pass

func on_trap_encounter(defended: bool, keyword: String) -> void:
	pass

func on_ghost_encounter(defended: bool) -> void:
	pass

# can't really be defended
func on_abomination_encounter(defended: bool) -> void:
	pass

func on_wild_potion() -> void:
	pass

func on_wild_gargoyle() -> void:
	pass

func on_wild_bat() -> void:
	pass

func on_ace_found() -> void:
	pass

func on_saferoom_reached() -> void:
	pass

func on_saferoom_rest() -> void:
	pass

func on_saferoom_meditate() -> void:
	pass

func on_saferoom_plead() -> void:
	pass

func on_saferoom_search(found: bool, item: HauntedHouseGamePlayer.Item) -> void:
	pass

func on_queen_spotted() -> void:
	pass

func on_queen_heal() -> void:
	pass

func on_queen_calm() -> void:
	pass

func on_queen_soothe() -> void:
	pass

func on_queen_gift() -> void:
	pass

func on_game_over_dead() -> void:
	pass

func on_game_over_cursed() -> void:
	pass

func on_game_over_angry() -> void:
	pass

func on_game_won() -> void:
	pass
