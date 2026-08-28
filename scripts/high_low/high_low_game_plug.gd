extends GamePlug
class_name HighLowGamePlug

# must self enforce a max number of wrong guesses
const MAX_WRONG_GUESSES = 20

var health: int = 20

func on_game_started() -> void:
	portrait.try_load_numbered_image(MAX_WRONG_GUESSES)

func on_guessed_incorrectly(suit_channel: int, was_same: bool) -> void:
	if suit_channel == _get_suit_channel() and not was_same:
		health -= 1
		PortraitHelper.seeburg_select(portrait, health, MAX_WRONG_GUESSES, -1)
