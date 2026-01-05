extends GamePlug
class_name WarGamePlug

const COMBINED_CHANNEL = 0
const RED_CHANNEL = 1
const BLUE_CHANNEL = 2

const COMBINED_RED_WIN_SUBDIR = "red"
const COMBINED_BLUE_WIN_SUBDIR = "blue"
const COMBINED_TIE_SUBDIR = "tie"

const SEPARATE_WIN_SUBDIR = "win"
const SEPARATE_LOSE_SUBDIR = "lose"
const SEPARATE_TIE_SUBDIR = "tie"

# usually, the score will be around 13:13, give or take a few
# ties will cause it to vary more

# I'm thinking the opposite player's score will be sort of like
# how much damage you have taken, and that's how the images should
# be thought about.

# 2 Ideas: 2 panes each representing a different character, or
# 1 pane representing a single permutation of 2 characters with
# appropriate images based on score ratios

# Maybe both? If on channel 0, the latter. If on 1 or 2, red or blue
# respectively.

func on_game_over(red_score: int, blue_score: int) -> void:
	var suit_channel = _get_suit_channel()
	var did_red_win = red_score > blue_score
	var tied = red_score == blue_score
	if suit_channel == COMBINED_CHANNEL:
		if did_red_win:
			portrait.try_load_random_image_from_subdir(COMBINED_RED_WIN_SUBDIR)
		elif tied:
			portrait.try_load_random_image_from_subdir(COMBINED_TIE_SUBDIR)
		else: # blue won
			portrait.try_load_random_image_from_subdir(COMBINED_BLUE_WIN_SUBDIR)
	elif suit_channel == RED_CHANNEL:
		if did_red_win:
			portrait.try_load_random_image_from_subdir(SEPARATE_WIN_SUBDIR)
		elif tied:
			portrait.try_load_random_image_from_subdir(SEPARATE_TIE_SUBDIR)
		else: # blue won
			portrait.try_load_random_image_from_subdir(SEPARATE_LOSE_SUBDIR)
	elif suit_channel == BLUE_CHANNEL:
		if did_red_win:
			portrait.try_load_random_image_from_subdir(SEPARATE_LOSE_SUBDIR)
		elif tied:
			portrait.try_load_random_image_from_subdir(SEPARATE_TIE_SUBDIR)
		else: # blue won
			portrait.try_load_random_image_from_subdir(SEPARATE_WIN_SUBDIR)

func on_game_started() -> void:
	portrait.try_load_numbered_image(0)

func on_round_tied(_red_score: int, _blue_score: int) -> void:
	# state doesn't change until a tie is broken...
	pass

func on_round_won(_did_red_win: bool, red_score: int, blue_score: int) -> void:
	var suit_channel = _get_suit_channel()
	# negative means blue is winning, positive means red is winning
	# for blue_channel, negate this and use that image instead (this makes
	# each character channel-agnostic)
	var r2b_score_ratio = red_score - blue_score
	if suit_channel == COMBINED_CHANNEL or suit_channel == RED_CHANNEL:
		var step = 1
		if r2b_score_ratio < 0:
			step = -1
		PortraitHelper.seeburg_select(portrait, 0, r2b_score_ratio, step)
	elif suit_channel == BLUE_CHANNEL:
		var inverted_ratio = -r2b_score_ratio
		var step = 1
		if inverted_ratio < 0:
			step = -1
		PortraitHelper.seeburg_select(portrait, 0, inverted_ratio, step)
