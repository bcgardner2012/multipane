extends GamePlug
class_name BetrothalGamePlug

func on_game_won() -> void:
	portrait.try_load_random_image_from_subdir("betrothed")

func on_card_drawn(_card: CardData) -> void:
	portrait.try_load_random_image_from_subdir("draw")

func on_cards_removed(_count: int) -> void:
	if _count == 1:
		portrait.try_load_random_image_from_subdir("one")
	else:
		portrait.try_load_random_image_from_subdir("two")
