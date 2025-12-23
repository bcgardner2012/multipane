extends Node
class_name Area52GamePlug

@export var portrait: Portrait

const DEFENDER_CHANNEL = 3
const DUAL_ATTACK_FOLDER = "double"
const SINGLE_ATTACK_FOLDER = "single"
const SACRIFICE_FOLDER = "sacrifice"

# increment the index for every attack and sacrifice performed. Use this to figure out
# which pane/suit-channel to update.
# reset to 0 when aliens are drawn
var index: int

# determine an index to show in each pane. Use suit tool as a channel selector.
func on_aliens_drawn(aliens: Array[CardData]) -> void:
	index = 0
	if _get_suit_channel() < 3 and aliens.size() > _get_suit_channel():
		# this means we MUST provide an image for Aces as 14.jpg or png
		PortraitHelper.seeburg_select(portrait, aliens[_get_suit_channel()].rank, 15)

# display an image using Scoundrel rules, interpreting deck_size as cur health
# always on the same channel, not affected by index
func on_defender_drawn(deck_size: int) -> void:
	if _get_suit_channel() == 3:
		PortraitHelper.seeburg_select(portrait, deck_size, 21)

# double folder
func on_dual_attack_performed(target: CardData) -> void:
	_seeburg_and_increment(target, DUAL_ATTACK_FOLDER)

# single folder
func on_single_attack_performed(target: CardData) -> void:
	_seeburg_and_increment(target, SINGLE_ATTACK_FOLDER)

# sacrifice folder
func on_sacrifice_performed(target: CardData) -> void:
	_seeburg_and_increment(target, SACRIFICE_FOLDER)

func _get_suit_channel() -> int:
	return get_parent().suit_channel

func _seeburg_and_increment(target: CardData, folder: String) -> void:
	if _get_suit_channel() == index:
		PortraitHelper.seeburg_select_subdir(portrait, target.rank, 15, folder)
	index += 1
	index %= 3
