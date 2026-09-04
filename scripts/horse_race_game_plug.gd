extends GamePlug
class_name HorseRaceGamePlug

# Modes
const FIRST_MONITOR = 0 # track who's in first, escalate w #moves
const SECOND_MONITOR = 1 # track who's in second, escalate w #moves
const PLAYER_WALLET = 2 # track only the player's current cash, escalate with log10
const ALL_WALLETS = 3 # track current cash for whoever won the bet, prioritize player

const PLAYER_DIR = "player" # /<log10_wealth>
const HORSE_DIR = "horse" # /suit/<#moves>
const NPC_DIR ="npc" # /suit/<log10_wealth>

var move_counts: Dictionary = {
	0: 0,
	1: 0,
	2: 0,
	3: 0
}

func on_moved(horse: CardData.Suit) -> void:
	move_counts[horse] += 1
	var keys = _sort_move_counts()
	
	var place = 0
	var channel = _get_suit_channel()
	if channel == FIRST_MONITOR:
		place = keys[0]
	elif channel == SECOND_MONITOR:
		place = keys[1]
	
	if channel == FIRST_MONITOR or channel == SECOND_MONITOR:
		var dir = HORSE_DIR.path_join(_suit_to_str(place))
		# 8 is a win
		if not PortraitHelper.seeburg_select_subdir(portrait, move_counts[place], 9, dir):
			portrait.try_load_random_image_from_subdir(dir)

func on_player_won(cash: int) -> void:
	var channel = _get_suit_channel()
	if channel == PLAYER_WALLET:
		_show_wealth_img(PLAYER_DIR, cash)

func on_npc_won(npc: CardData.Suit, cash: int, player_cash: int) -> void:
	var channel = _get_suit_channel()
	# player wealth went down, reflect that
	if channel == PLAYER_WALLET:
		_show_wealth_img(PLAYER_DIR, player_cash)
	elif channel == ALL_WALLETS:
		_show_wealth_img(NPC_DIR.path_join(_suit_to_str(npc)), cash)

func _show_wealth_img(dir: String, cash: int) -> void:
	# log10 of x round down gives number of digits - 1
	# use this to select image, 1-by-1 iteration up to 1 million will drag on...
	var wealth_lvl: int = log10(cash) # -10 to 10, then integer overflow
	if not PortraitHelper.seeburg_select_subdir(portrait, wealth_lvl, 10, dir):
		portrait.try_load_random_image_from_subdir(dir)

# clear data
func on_race_started() -> void:
	move_counts = {
		0: 0,
		1: 0,
		2: 0,
		3: 0
	}

# return array of map keys in order greatest to least
func _sort_move_counts() -> Array[int]:
	var keys = move_counts.keys()
	keys.sort_custom(func (a, b):
		return move_counts[a] > move_counts[b]
	)
	return keys

func _suit_to_str(suit: CardData.Suit) -> String:
	match suit:
		CardData.Suit.HEARTS:
			return "heart"
		CardData.Suit.DIAMONDS:
			return "diamond"
		CardData.Suit.CLUBS:
			return "club"
		CardData.Suit.SPADES:
			return "spade"
	return ""

# counts number of digits in x, -1
func log10(x: int) -> int:
	return log(x) / log(10)
