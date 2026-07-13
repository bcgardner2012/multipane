extends ScoringScoundrelBrain
class_name HCScoringScoundrelBrain

# 1 HP is worth 1 HPC (Health Point Currency)
# A weapon is worth (dur - rank) * rank + sum(i, 2, min(rank - 1, dur))
# ie, the amount of HP it can possibly save you with the best possible usage
# The cost of using current weapon on a monster is its value equation before minus
# its value equation after.
# A monster is worth it's rank in HPC unarmed, or rank - weapon_rank armed.
# HPC cost of fighting monsters is already encoded in the player's health and
# weapon durabilities at room end.

# Note: taking only the end state of a permutation diregards the cost of throwing
# away weapons (ie, in red flush rooms with 2+ weapons)

@export var survivability_modifier: float # Multiplies calculations around direct health loss by this value when determining whether to use weapons
@export var smash_modifier: float # Multiplies lost health value due to smashing potions by this value to discourage that behavior.
@export var weak_weapon_threshold: int # Any weapon at or below this rank will be used, regardless of other weapon usage logic

func _score_state(health: int, weapon_durability: int, weapon_rank: int, overheal_amount: int, wasted_potions: Array[CardData], killed_monsters: Array[CardData], weapon_uses: Array[WeaponDelta]):
	# a change in health in the permutation being evaluated
	var health_delta = health - _health()
	var durability_delta_hpc = _evaluate_total_weapon_hpc(weapon_uses)
	return health_delta * health_delta_weight - durability_delta_hpc - overheal_amount * overheal_amount_weight - (_sum(wasted_potions) * smash_modifier)

func _evaluate_total_weapon_hpc(weapon_uses: Array[WeaponDelta]) -> float:
	var consumed_hpc = 0
	for wd in weapon_uses:
		# same weapon, lose dur based HPC
		if wd.pre_rank == wd.post_rank:
			consumed_hpc += _evaluate_weapon_at_durability(wd.pre_durability, wd.pre_rank) \
			- _evaluate_weapon_at_durability(wd.post_durability, wd.post_rank) 
		# weapon swap, lose cur weapon HPC
		else:
			consumed_hpc += _evaluate_weapon_at_durability(wd.pre_durability, wd.pre_rank)
		
		# swapped weapons before even using the original one? Discourage this.
		if wd.pre_durability == 15 and wd.post_durability == 15:
			consumed_hpc += weapon_change_while_cur_weapon_imm_useful_weight
	
	return consumed_hpc

func _evaluate_weapon_at_durability(weapon_durability: int, weapon_rank: int) -> float:
	var term1 = maxi(weapon_durability - weapon_rank, 0) * weapon_rank
	var term2 = _sumi(2, weapon_rank)
	return term1 + term2

func _sumi(from: int, to: int) -> int:
	var s = 0
	for i in range(from, to):
		s += i
	return s

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
		"Health Delta: " + str(h - _health()),
		"Weapon Delta: " + str(-_evaluate_total_weapon_hpc(weapon_uses)),
		"Overheal: " + str(-overheal_amount),
		"Wasted Potions Sum: " + str(_sum(wasted_potions))
]

func _should_use_weapon(monster: CardData, virtual_durability: int, virtual_weapon_rank: int, virtual_health: int):
	if virtual_durability <= 2 or virtual_weapon_rank == 0:
		return false
	if monster.rank >= virtual_durability:
		return false   # weapon can't be used on this one anymore
	if monster.rank >= virtual_health:
		return true
	if weak_weapon_threshold >= virtual_weapon_rank:
		return true
	# If HPC value of weapon dmg is less than taking dmg on the chin, then use weapon
	return _evaluate_weapon_at_durability(virtual_durability, virtual_weapon_rank) \
	- _evaluate_weapon_at_durability(monster.rank, virtual_weapon_rank) \
	<= monster.rank * survivability_modifier
