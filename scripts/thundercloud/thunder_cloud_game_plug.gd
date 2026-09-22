extends GamePlug
class_name ThundercloudGamePlug

const P1_COLOR = Color.RED
const P2_COLOR = Color.GREEN
const P3_COLOR = Color.BLUE

const P1_CHANNEL = 0
const P2_CHANNEL = 1
const P3_CHANNEL = 2

const STRUCK_DIR = "struck"
const SAFE_DIR = "safe"
const WIN_DIR = "win"

func on_game_over(winner: Color) -> void:
	match _get_suit_channel():
		P1_CHANNEL:
			_show_win(winner, P1_COLOR)
		P2_CHANNEL:
			_show_win(winner, P2_COLOR)
		P3_CHANNEL:
			_show_win(winner, P3_COLOR)

func on_struck(color: Color) -> void:
	match _get_suit_channel():
		P1_CHANNEL:
			_show_struck(color, P1_COLOR)
		P2_CHANNEL:
			_show_struck(color, P2_COLOR)
		P3_CHANNEL:
			_show_struck(color, P3_COLOR)

func on_not_struck(color: Color) -> void:
	match _get_suit_channel():
		P1_CHANNEL:
			_show_not_struck(color, P1_COLOR)
		P2_CHANNEL:
			_show_not_struck(color, P2_COLOR)
		P3_CHANNEL:
			_show_not_struck(color, P3_COLOR)

func _show_not_struck(player: Color, expected: Color) -> void:
	_show(player, expected, SAFE_DIR)

func _show_struck(player: Color, expected: Color) -> void:
	_show(player, expected, STRUCK_DIR)

func _show_win(winner: Color, expected: Color) -> void:
	_show(winner, expected, WIN_DIR)

func _show(player: Color, expected: Color, dir: String) -> void:
	if player == expected:
		portrait.try_load_random_image_from_subdir(dir)
