extends GamePlug
class_name BeetleGamePlug

# idea for imagery: the players are growing a bug. Each part added increments
# a counter, we show an ever larger version of their bug.
var part_count: int

func on_game_over(_index: int) -> void:
	pass

func on_part_added(_index: int) -> void:
	var channel = _get_suit_channel() # player 0 - 2
	if channel == _index:
		part_count += 1
		PortraitHelper.seeburg_select(portrait, 0, part_count +1)
