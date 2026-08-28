extends GamePlug
class_name JokerJailbreakGamePlug

# stack indexes
const TC = 1 # top-center
const MR = 5
const BC = 7
const ML = 3

# Just show 0.jpg or 0.png
func on_game_won() -> void:
	portrait.try_load_numbered_image(0)

# I'm thinking we show images 7 -> 0 based on smallest stack
func on_chipped(all_stacks: Array[Array]) -> void:
	var _min = 7
	_min = mini(_min, all_stacks[TC].size())
	_min = mini(_min, all_stacks[MR].size())
	_min = mini(_min, all_stacks[BC].size())
	_min = mini(_min, all_stacks[ML].size())
	PortraitHelper.seeburg_select(portrait, _min, 8)
