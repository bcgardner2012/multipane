extends GamePlug
class_name SnakeCharmerGamePlug

func on_player_bit(index: int) -> void:
	if index == _get_suit_channel():
		portrait.try_load_random_image_from_subdir("bit")

func on_player_lost(index: int) -> void:
	if index == _get_suit_channel():
		portrait.try_load_random_image_from_subdir("lost")

func on_player_attempting_to_capture(index: int) -> void:
	if index == _get_suit_channel():
		portrait.try_load_random_image_from_subdir("close")

func on_player_won(index: int) -> void:
	if index == _get_suit_channel():
		portrait.try_load_random_image_from_subdir("won")

func on_player_rolled(index: int) -> void:
	if index == _get_suit_channel():
		portrait.try_load_random_image_from_subdir("roll")
