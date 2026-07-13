extends ScoringScoundrelBrain
class_name NonlinearScoringScoundrelBrain

func _score_state(health: int, weapon_durability: int, weapon_rank: int, overheal_amount: int, wasted_potions: Array[CardData], killed_monsters: Array[CardData], weapon_uses: Array[WeaponDelta]):
	return log(health) * health_weight \
	+ (health - _health()) * health_delta_weight \
	+ (10.0 / weapon_rank) * weapon_rank_weight \
	+ (weapon_rank - game_player.equipped_weapon.rank) * weapon_rank_delta_weight if game_player.equipped_weapon != null else 0.0 \
	+ weapon_durability * durability_weight \
	+ (15.0 / (weapon_durability - game_player.durability)) * durability_delta_weight \
	+ weapon_change_while_cur_weapon_imm_useful_weight if _weapon_is_immediately_useful() else 0.0 \
	+ overheal_amount * overheal_amount * overheal_amount_weight \
	+ wasted_potions.size() * potion_wastage_count_weight \
	+ _sum(wasted_potions) * _sum(wasted_potions) * potion_wastage_sum_weight \
	+ killed_monsters.size() * monsters_killed_count_weight \
	+ _sum(killed_monsters) * monsters_killed_sum_weight \
	+ monsters_killed_in_desc_order_weight if _is_descending(killed_monsters) else 0.0


func _get_debug_breakdown(\
	h: int, \
	virtual_weapon_rank: int, \
	virtual_durability: int, \
	overheal_amount: int, \
	wasted_potions: Array[CardData], \
	killed_monsters: Array[CardData], \
	weapon_uses: Array[WeaponDelta] \
) -> Array[String]:
	return [
		"Health: " + str(log(h) * health_weight),
		"Health Delta: " + str((h - _health()) * health_delta_weight),
		"Weapon Rank: " + str((10.0 / virtual_weapon_rank) * weapon_rank_weight),
		"WRank Delta: " + str((virtual_weapon_rank - game_player.equipped_weapon.rank) * weapon_rank_delta_weight if game_player.equipped_weapon != null else 0.0),
		"Durability: " + str(virtual_durability * durability_weight),
		"Durability Delta: " + str((15.0 / (virtual_durability - game_player.durability)) * durability_delta_weight),
		"Change while useful: " + str(weapon_change_while_cur_weapon_imm_useful_weight if _weapon_is_immediately_useful() else 0.0),
		"Overheal: " + str(overheal_amount * overheal_amount_weight),
		"Wasted Potions #: " + str(wasted_potions.size() * potion_wastage_count_weight),
		"Wasted Potions Sum: " + str(_sum(wasted_potions) * _sum(wasted_potions) * potion_wastage_sum_weight),
		"Monster Kill #: " + str(killed_monsters.size() * monsters_killed_count_weight),
		"Monster Kill Sum: " + str(_sum(killed_monsters) * monsters_killed_sum_weight),
		"Killed Desc: " + str(monsters_killed_in_desc_order_weight if _is_descending(killed_monsters) else 0.0)
	]
