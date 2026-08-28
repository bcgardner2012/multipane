extends ScoundrelBrain
class_name ScoringScoundrelBrain

# This overwrites the core turn logic entirely of the AI. Instead of considering
# each card one-by-one and evaluating whether it alone is a good play, this will
# using a scoring algorithm to score permutations of all possible actions in a
# room, and choosing the plan of action with the highest score.

# Scoring weights
@export var health_weight: float # Score multiplier for final health once a plan is executed
@export var health_delta_weight: float # Score multiplier against amount of health lost
@export var weapon_rank_weight: float # Score multiplier for final weapon rank once a plan is executed
@export var weapon_rank_delta_weight: float # Score multiplier for change in weapon rank
@export var durability_weight: float # Score multiplier for final weapon durability once a plan is executed
@export var durability_delta_weight: float # Score multiplier for durability change
@export var weapon_change_while_cur_weapon_imm_useful_weight: float # Score multiplier for swapping weapons while the current one is still perfectly usable right now
@export var overheal_amount_weight: float # Score multiplier for amount of health overhealed (potential wasted) from a potion
@export var potion_wastage_count_weight: float # Score multiplier for number of potions smashed
@export var potion_wastage_sum_weight: float # Score multiplier for total healing potential lost due to smashed potions
@export var monsters_killed_count_weight: float # Score multiplier for number of monsters killed in current room
@export var monsters_killed_sum_weight: float # Score multiplier for sum of potential damage removed due to sum of killed monster ranks
@export var monsters_killed_in_desc_order_weight: float # Score multiplier for killing monsters in descending order

@export var _description_: String

var _current_plan: Array[CardData] = []
var _room_number: int = 0

func _do_turn() -> void:
	if _health() <= 0:
		# I died...
		deactivate()
		return
	
	# if cards_resolved is 0, we need to get and sort cards
	if _on_new_room():
		return
	
	# if cards_resolved is 3, reset to 0 and wait for the next frame
	if _on_room_cleared():
		return
	
	if _current_plan == []:
		_room_number += 1
		_current_plan = _get_best_play(sorted_cards)
	
	var card = _current_plan.pop_front()
	var button = MOUSE_BUTTON_LEFT
	if (card as CardData).is_black() and game_player.equipped_weapon != null and not _should_use_weapon(card, game_player.durability, game_player.equipped_weapon.rank, _health()):
		button = MOUSE_BUTTON_RIGHT
	
	_play(card, button)


func _get_best_play(room: Array[CardData]) -> Array[CardData]:
	# room = list of 4 cards; weapon = {value, lastKilled} or None
	var best = null

	for keepChoice in choose3of4(room):        # which card to leave behind
		var remainingCard = _subtract_arrays(room, keepChoice)
		for ordering in _all_permutations(keepChoice):
			var casted_ordering = CardDataArrayHelper.cast_to_card_data_array(ordering)
			var outcome = _simulate_ordering(casted_ordering)
			if best == null or (outcome.survived and outcome.score > best.score):
				best = outcome
				best.leftBehind = remainingCard
				best.ordering = casted_ordering
	
	print("--------- Room " + str(_room_number) + " ----------")
	print("OK! Here's my plan...")
	var _debug = ""
	for card in best.ordering:
		_debug += card.get_abbreviation() + " "
	if best.leftBehind != []:
		print("I will ignore " + best.leftBehind[0].get_abbreviation())
	print(_debug)
	print("Total Score: " + str(best.score))
	print("Based on this breakdown:")
	for bd in best.debug_breakdown:
		print(bd)
	print("--------- Room " + str(_room_number) + " ----------")
	
	return best.ordering

func choose3of4(room: Array[CardData]) -> Array:
	if room.size() < 4:
		return [room.duplicate()]
	return [
		[room[0], room[1], room[2]],
		[room[0], room[1], room[3]],
		[room[0], room[2], room[3]],
		[room[1], room[2], room[3]]
	]

func _simulate_ordering(cards: Array[CardData]):
	var potionUsedThisRoom = false
	var h = _health()
	var virtual_durability = game_player.durability
	var virtual_weapon_rank = 0
	if game_player.equipped_weapon != null:
		virtual_weapon_rank = game_player.equipped_weapon.rank
	
	var overheal_amount: int = 0
	var wasted_potions: Array[CardData] = []
	var killed_monsters: Array[CardData] = []
	var weapon_uses: Array[WeaponDelta] = [] # we need the rank[0] and durability[1] at toss

	for card in cards:
		var damage = 0
		if card.suit == CardData.Suit.HEARTS:
			if not potionUsedThisRoom:
				var sum = h + card.rank
				overheal_amount += 0 if sum <= 20 else sum - 20
				h = min(20, sum)
				potionUsedThisRoom = true
			else: #wasted, no effect (unless you allow "drink to discard" logic)
				wasted_potions.append(card)

		elif card.suit == CardData.Suit.DIAMONDS:
			if virtual_weapon_rank != 0:
				weapon_uses.append(WeaponDelta.new(virtual_durability, virtual_weapon_rank, 15, card.rank))
			virtual_durability = 15
			virtual_weapon_rank = card.rank

		elif card.is_black():
			var useWeapon = _should_use_weapon(card, virtual_durability, virtual_weapon_rank, h)
			if useWeapon:
				weapon_uses.append(WeaponDelta.new(virtual_durability, virtual_weapon_rank, card.rank, virtual_weapon_rank))
				damage = max(0, card.rank - virtual_weapon_rank)
				virtual_durability = card.rank
			else:
				damage = card.rank
			h -= damage
			if h <= 0:
				return {"survived": false, "score": -9999, "debug_breakdown": []}
			killed_monsters.append(card)

	return {
		"survived": true,
		"score": _score_state(\
			h, \
			virtual_durability, \
			virtual_weapon_rank, \
			overheal_amount, \
			wasted_potions, \
			killed_monsters, \
			weapon_uses \
		),
		"debug_breakdown": _get_debug_breakdown(\
			h, \
			virtual_weapon_rank, \
			virtual_durability, \
			overheal_amount, \
			wasted_potions, \
			killed_monsters, \
			weapon_uses
		)
	}

func _get_debug_breakdown(\
	h: int, \
	virtual_weapon_rank: int, \
	virtual_durability: int, \
	overheal_amount: int, \
	wasted_potions: Array[CardData], \
	killed_monsters: Array[CardData], \
	weapon_uses: Array[WeaponDelta]
) -> Array[String]:
	return [
		"Health: " + str(h * health_weight),
		"Health Delta: " + str((h - _health()) * health_delta_weight),
		"Weapon Rank: " + str(virtual_weapon_rank * weapon_rank_weight),
		"WRank Delta: " + str((virtual_weapon_rank - game_player.equipped_weapon.rank) * weapon_rank_delta_weight if game_player.equipped_weapon != null else 0.0),
		"Durability: " + str(virtual_durability * durability_weight),
		"Durability Delta: " + str((virtual_durability - game_player.durability) * durability_delta_weight),
		"Change while useful: " + str(weapon_change_while_cur_weapon_imm_useful_weight if _weapon_is_immediately_useful() else 0.0),
		"Overheal: " + str(overheal_amount * overheal_amount_weight),
		"Wasted Potions #: " + str(wasted_potions.size() * potion_wastage_count_weight),
		"Wasted Potions Sum: " + str(_sum(wasted_potions) * potion_wastage_sum_weight),
		"Monster Kill #: " + str(killed_monsters.size() * monsters_killed_count_weight),
		"Monster Kill Sum: " + str(_sum(killed_monsters) * monsters_killed_sum_weight),
		"Killed Desc: " + str(monsters_killed_in_desc_order_weight if _is_descending(killed_monsters) else 0.0)
	]

func _all_permutations(arr: Array) -> Array:
	var result: Array = []
	_all_permutations_helper(arr.duplicate(), arr.size(), result)
	return result

func _all_permutations_helper(a: Array, n: int, result: Array) -> void:
	if n == 1:
		# Store a copy to avoid reference issues
		result.append(a.duplicate())
	else:
		for i in range(n):
			_all_permutations_helper(a, n - 1, result)
			if n % 2 == 1:
				# Swap current element with last
				var tmp = a[i]
				a[i] = a[n - 1]
				a[n - 1] = tmp
			else:
				# Swap first element with last
				var tmp = a[0]
				a[0] = a[n - 1]
				a[n - 1] = tmp

func _should_use_weapon(monster: CardData, virtual_durability: int, virtual_weapon_rank: int, virtual_health: int):
	if virtual_durability <= 2 or virtual_weapon_rank == 0:
		return false
	if monster.rank >= virtual_durability:
		return false   # weapon can't be used on this one anymore
	return true         # simple version: always use weapon if legal

func _score_state(health: int, weapon_durability: int, weapon_rank: int, overheal_amount: int, wasted_potions: Array[CardData], killed_monsters: Array[CardData], weapon_uses: Array[WeaponDelta]):
	return health * health_weight \
	+ (health - _health()) * health_delta_weight \
	+ weapon_rank * weapon_rank_weight \
	+ (weapon_rank - game_player.equipped_weapon.rank) * weapon_rank_delta_weight if game_player.equipped_weapon != null else 0.0 \
	+ weapon_durability * durability_weight \
	+ (weapon_durability - game_player.durability) * durability_delta_weight \
	+ weapon_change_while_cur_weapon_imm_useful_weight if _weapon_is_immediately_useful() else 0.0 \
	+ overheal_amount * overheal_amount_weight \
	+ wasted_potions.size() * potion_wastage_count_weight \
	+ _sum(wasted_potions) * potion_wastage_sum_weight \
	+ killed_monsters.size() * monsters_killed_count_weight \
	+ _sum(killed_monsters) * monsters_killed_sum_weight \
	+ monsters_killed_in_desc_order_weight if _is_descending(killed_monsters) else 0.0

func _is_descending(cards: Array[CardData]) -> bool:
	if cards.size() <= 1:
		return true
	
	for i in range(cards.size() - 1):
		# If any number is smaller than the next, it is not descending
		if cards[i].rank < cards[i + 1].rank:
			return false
			
	return true

func _subtract_arrays(a: Array, b: Array) -> Array:
	# Duplicate so we don't modify the original array
	var result := a.duplicate()
	for item in b:
		result.erase(item)  # Removes first occurrence if found
	return result

func _sum(cards: Array[CardData]) -> int:
	var s = 0
	for card in cards:
		s += card.rank
	return s
