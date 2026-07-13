extends ScoundrelBrain
class_name UnarmedAversionScoundrelBrain

# this AI still has a problem with grabbing new weapons when the old could still
# kill something with 0 dmg taken.

func _is_armed_attack_optimal(card: CardData) -> bool:
	return _is_armed_dmg_tolerable(card)

func _is_weapon_swap_tolerable(card: CardData) -> bool:
	return game_player.equipped_weapon == null or (game_player.durability < 7 and not _weapon_is_immediately_useful())

func _weapon_is_immediately_useful() -> bool:
	for card in sorted_cards:
		if card.suit == CardData.Suit.CLUBS or card.suit == CardData.Suit.SPADES:
			if game_player.durability > card.rank:
				return true
	return false

func _weapon_is_immediately_useful_without_dmg() -> bool:
	for card in sorted_cards:
		if card.suit == CardData.Suit.CLUBS or card.suit == CardData.Suit.SPADES:
			if game_player.durability == card.rank + 1 and game_player.equipped_weapon.rank >= card.rank:
				return true
	return false

func _is_unarmed_dmg_tolerable(_card: CardData) -> bool:
	# only tolerable when we can heal immediately, as much dmg as taken
	var immediate_heal_potential = 0
	var min_dmg_to_take = 99
	for card in sorted_cards:
		if card.suit == CardData.Suit.HEARTS:
			immediate_heal_potential = maxi(immediate_heal_potential, card.rank)
		elif card.suit == CardData.Suit.CLUBS or card.suit == CardData.Suit.SPADES:
			min_dmg_to_take = mini(min_dmg_to_take, card.rank)
	return min_dmg_to_take <= immediate_heal_potential

# improvement: AI was healing when the weapon could kill an enemy while losing only 1 durability and no health
func _is_heal_tolerable(card: CardData) -> bool:
	var dmg = 20 - _health()
	if dmg >= card.rank - 0: # means we will waste no HP from a potion.
		return not _weapon_is_immediately_useful_without_dmg()
	return false
