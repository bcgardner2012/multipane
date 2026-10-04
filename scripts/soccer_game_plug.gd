extends GamePlug
class_name SoccerGamePlug

# The only thing we can really monitor is who kicked the ball last, and whether
# it resulted in a goal.

const KICK_DIR = "kick"
const GOAL_DIR = "goal"
const HEARTS = "hearts"
const SPADES = "spades"

func on_kicked(card: CardData) -> void:
	if card.suit == CardData.Suit.HEARTS:
		portrait.try_load_random_image_from_subdir(KICK_DIR.path_join(HEARTS))
	else:
		portrait.try_load_random_image_from_subdir(KICK_DIR.path_join(SPADES))

func on_goal(card: CardData) -> void:
	if card.suit == CardData.Suit.HEARTS:
		portrait.try_load_random_image_from_subdir(GOAL_DIR.path_join(HEARTS))
	else:
		portrait.try_load_random_image_from_subdir(GOAL_DIR.path_join(SPADES))

func on_game_won() -> void:
	portrait.try_load_random_image_from_subdir("win")

func on_game_lost() -> void:
	portrait.try_load_random_image_from_subdir("lose")

func on_game_tied() -> void:
	portrait.try_load_random_image_from_subdir("tie")
