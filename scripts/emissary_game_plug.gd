extends Node
class_name EmissaryGamePlug

@export var portrait: Portrait

# signals
const ADVISOR_FOLDER = "advisors"
const LOST_GAME_FOLDER = "lost"
const DEBATE_STARTED_FOLDER = "start"
const TOPIC_WIN_FOLDER = "topic/win"
const TOPIC_LOSE_FOLDER = "topic/lose"
const GAME_WON_FOLDER = "won"

# kingdoms
const QH_SUBDIR = "qh"
const QC_SUBDIR = "qc"
const QS_SUBDIR = "qs"
const QD_SUBDIR = "qd"
const KH_SUBDIR = "kh"
const KC_SUBDIR = "kc"
const KS_SUBDIR = "ks"
const KD_SUBDIR = "kd"

# advisors
const HEARTS_SUBDIR = "hearts"
const CLUBS_SUBDIR = "clubs"
const SPADES_SUBDIR = "spades"
const DIAMONDS_SUBDIR = "diamonds"

func on_advisor_consulted(suit: CardData.Suit) -> void:
	var path = ADVISOR_FOLDER
	match suit:
		CardData.Suit.HEARTS:
			path.path_join(HEARTS_SUBDIR)
		CardData.Suit.DIAMONDS:
			path.path_join(DIAMONDS_SUBDIR)
		CardData.Suit.CLUBS:
			path.path_join(CLUBS_SUBDIR)
		CardData.Suit.SPADES:
			path.path_join(SPADES_SUBDIR)

	if not portrait.try_load_random_image_from_subdir(path):
		portrait.try_load_random_image_from_subdir(ADVISOR_FOLDER)

func on_debate_started(kingdom: CardData) -> void:
	var path = DEBATE_STARTED_FOLDER
	_path_join_by_rank_and_suit(path, kingdom)
	
	if not portrait.try_load_random_image_from_subdir(path):
		portrait.try_load_random_image_from_subdir(DEBATE_STARTED_FOLDER)

func _path_join_by_rank_and_suit(path: String, kingdom: CardData) -> void:
	match kingdom.suit:
		CardData.Suit.HEARTS:
			_path_join_by_rank(path, kingdom, KH_SUBDIR, QH_SUBDIR)
		CardData.Suit.DIAMONDS:
			_path_join_by_rank(path, kingdom, KD_SUBDIR, QD_SUBDIR)
		CardData.Suit.CLUBS:
			_path_join_by_rank(path, kingdom, KC_SUBDIR, QC_SUBDIR)
		CardData.Suit.SPADES:
			_path_join_by_rank(path, kingdom, KS_SUBDIR, QS_SUBDIR)

func _path_join_by_rank(path: String, kingdom: CardData, kSubdir: String, qSubdir: String) -> void:
	if kingdom.rank == 13:
		path.path_join(kSubdir)
	elif kingdom.rank == 12:
		path.path_join(qSubdir)

func on_lost_kingdom(kingdom: CardData) -> void:
	var path = LOST_GAME_FOLDER
	_path_join_by_rank_and_suit(path, kingdom)
	
	if not portrait.try_load_random_image_from_subdir(path):
		portrait.try_load_random_image_from_subdir(LOST_GAME_FOLDER)

func on_lost_topic(kingdom: CardData, _losing_card: CardData) -> void:
	var path = TOPIC_LOSE_FOLDER
	_path_join_by_rank_and_suit(path, kingdom)
	
	if not portrait.try_load_random_image_from_subdir(path):
		portrait.try_load_random_image_from_subdir(TOPIC_LOSE_FOLDER)

func on_won_game(_last_kingdom: CardData) -> void:
	portrait.try_load_random_image_from_subdir(GAME_WON_FOLDER)

# Feels redundant with won_game... subdirs for kingdom, main dir for whole game
func on_won_kingdom(kingdom: CardData) -> void:
	var path = GAME_WON_FOLDER
	_path_join_by_rank_and_suit(path, kingdom)
	portrait.try_load_random_image_from_subdir(path)

func on_won_topic(kingdom: CardData, _winning_card: CardData) -> void:
	var path = TOPIC_WIN_FOLDER
	_path_join_by_rank_and_suit(path, kingdom)
	
	if not portrait.try_load_random_image_from_subdir(path):
		portrait.try_load_random_image_from_subdir(TOPIC_WIN_FOLDER)
