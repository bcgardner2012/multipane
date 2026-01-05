extends GamePlug
class_name BardsAndNoblesGamePlug

# support 3 channels: 0 next customer, 1 prev customer, 2 player char
# show next customer looking for an item or getting rid of one
# show prev customer using their new item or pouting for being turned away
# show player char giving or holding an item and ending scene (beheaded -> drowning in money)

const NEXT_CHANNEL = 0
const PREV_CHANNEL = 1
const PLAYER_CHANNEL = 2

# endings, use seeburg select to choose most relevant image
const ENDING_FOLDER = "ending"

# nobles
const QH_SUBDIR = "qh"
const QC_SUBDIR = "qc"
const QS_SUBDIR = "qs"
const QD_SUBDIR = "qd"
const KH_SUBDIR = "kh"
const KC_SUBDIR = "kc"
const KS_SUBDIR = "ks"
const KD_SUBDIR = "kd"
const JH_SUBDIR = "jh"
const JC_SUBDIR = "jc"
const JS_SUBDIR = "js"
const JD_SUBDIR = "jd"

# noble scenes
const ANGRY = "angry"
const HAPPY = "happy"
const BROWSE = "browse"

# player images
const PLAYER_FOLDER = "player"

const MIN_SCORE = -4

func on_customer_turned_away(customer: CardData, next: CardData) -> void:
	var channel = _get_suit_channel()
	if channel == NEXT_CHANNEL:
		# next browsing
		var notation = _card_to_notation(next)
		portrait.try_load_random_image_from_subdir(notation.path_join(BROWSE))
	elif channel == PREV_CHANNEL:
		# customer pouting
		var notation = _card_to_notation(customer)
		portrait.try_load_random_image_from_subdir(notation.path_join(ANGRY))
	elif channel == PLAYER_CHANNEL:
		# pick a random player idle
		portrait.try_load_random_image_from_subdir(PLAYER_FOLDER)
	
func on_game_over(score: int) -> void:
	var channel = _get_suit_channel()
	if channel != PLAYER_CHANNEL:
		return
	
	PortraitHelper.seeburg_select_subdir(portrait, score, MIN_SCORE, ENDING_FOLDER, -1)

func on_game_started(customer: CardData, _trade_in: CardData) -> void:
	var channel = _get_suit_channel()
	if channel == NEXT_CHANNEL:
		# next browsing
		var notation = _card_to_notation(customer)
		portrait.try_load_random_image_from_subdir(notation.path_join(BROWSE))
	elif channel == PREV_CHANNEL:
		# do nothing
		pass
	elif channel == PLAYER_CHANNEL:
		# pick a random player idle
		portrait.try_load_random_image_from_subdir(PLAYER_FOLDER)

# TODO? Consider score_delta for tipping player?
func on_sale_made(customer: CardData, _trade_in: CardData, _score_delta: int, next_customer: CardData) -> void:
	var channel = _get_suit_channel()
	if channel == NEXT_CHANNEL:
		# next browsing
		var notation = _card_to_notation(next_customer)
		portrait.try_load_random_image_from_subdir(notation.path_join(BROWSE))
	elif channel == PREV_CHANNEL:
		# customer happy
		var notation = _card_to_notation(customer)
		portrait.try_load_random_image_from_subdir(notation.path_join(HAPPY))
	elif channel == PLAYER_CHANNEL:
		# pick a random player idle
		portrait.try_load_random_image_from_subdir(PLAYER_FOLDER)

func _card_to_notation(card: CardData) -> String:
	match card.suit:
		CardData.Suit.HEARTS:
			if card.rank == 11:
				return JH_SUBDIR
			if card.rank == 12:
				return QH_SUBDIR
			if card.rank == 13:
				return KH_SUBDIR
		CardData.Suit.DIAMONDS:
			if card.rank == 11:
				return JD_SUBDIR
			if card.rank == 12:
				return QD_SUBDIR
			if card.rank == 13:
				return KD_SUBDIR
		CardData.Suit.CLUBS:
			if card.rank == 11:
				return JC_SUBDIR
			if card.rank == 12:
				return QC_SUBDIR
			if card.rank == 13:
				return KC_SUBDIR
		CardData.Suit.SPADES:
			if card.rank == 11:
				return JS_SUBDIR
			if card.rank == 12:
				return QS_SUBDIR
			if card.rank == 13:
				return KS_SUBDIR
	return ""
