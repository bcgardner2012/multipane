extends GamePane
class_name HauntedHouseGamePane

signal parrot_encounter(defended: bool)
signal spider_encounter(defended: bool)
signal rat_encounter(defended: bool)
signal trap_encounter(defended: bool, keyword: String)
signal ghost_encounter(defended: bool)
signal abomination_encounter(defended: bool) # can't really be defended

signal wild_potion()
signal wild_gargoyle()
signal wild_bat()

signal saferoom_rest()
signal saferoom_meditate()
signal saferoom_plead()
signal saferoom_search(found: bool, item: HauntedHouseGamePlayer.Item)

signal queen_heal()
signal queen_calm()
signal queen_soothe()
signal queen_gift()

signal game_over_dead()
signal game_over_cursed()
signal game_over_angry()

signal game_won()
