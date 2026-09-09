extends GamePlug
class_name ClubFightGamePlug

# I'm thinking just do 1 kind of image per MoveType, plus 2 overriding checks
# for Jokers. #cards could be a magnitude? Size of club deck could be interpreted
# as stamina or something.

const JOKER_RANK = -99

func on_move_made(move_type: ClubFightGamePlayer.MoveType, cards: Array[CardData]) -> void:
	if cards.size() > 4:
		portrait.try_load_random_image_from_subdir("nuke")
		return
	
	match move_type:
		ClubFightGamePlayer.MoveType.INVALID:
			return
		ClubFightGamePlayer.MoveType.MATCH:
			portrait.try_load_random_image_from_subdir("match")
		ClubFightGamePlayer.MoveType.SUM:
			portrait.try_load_random_image_from_subdir("sum")
		ClubFightGamePlayer.MoveType.ANY:
			if _contains_joker(cards):
				portrait.try_load_random_image_from_subdir("joker_any")
			else:
				portrait.try_load_random_image_from_subdir("any")
		ClubFightGamePlayer.MoveType.LINE:
			if _contains_joker(cards):
				portrait.try_load_random_image_from_subdir("joker_line")
			else:
				portrait.try_load_random_image_from_subdir("line")
		ClubFightGamePlayer.MoveType.UP_DOWN:
			portrait.try_load_random_image_from_subdir("up_down")
		ClubFightGamePlayer.MoveType.RUN:
			portrait.try_load_random_image_from_subdir("run")

func _contains_joker(cards: Array[CardData]) -> bool:
	for card in cards:
		if card != null and card.rank == JOKER_RANK:
			return true
	return false
