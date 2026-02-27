extends GamePlug
class_name OutrunGamePlug

const RED = 0
const BLUE = 1
const GREEN = 2

var health: int = 3
var captured_last_round: bool

func on_attacked(index: int) -> void:
	var channel = _get_suit_channel()
	if index == channel:
		health -= 1
		portrait.try_load_image(_index_to_color(channel).path_join(str(health)))
	
	# retain corpse image when bear moves on to next target
	if captured_last_round:
		portrait.try_load_image(_index_to_color(channel).path_join("corpse"))
		captured_last_round = false

func on_captured(index: int) -> void:
	var channel = _get_suit_channel()
	if index == channel:
		health = 0
		portrait.try_load_image(_index_to_color(channel).path_join(str(health)))
		captured_last_round = true

func on_game_started() -> void:
	var channel = _get_suit_channel()
	if channel < 3:
		portrait.try_load_image(_index_to_color(channel).path_join("3"))

func _index_to_color(index: int) -> String:
	match index:
		RED:
			return "red"
		BLUE:
			return "blue"
		GREEN:
			return "green"
	return ""
