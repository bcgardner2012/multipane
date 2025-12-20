extends Node
class_name ScoundrelGamePlug

@export var portrait: TextureRect
@export var health_bar: GaugeSlider
@export var folder_selector: FolderSelector

const UNARMED_ATTACK_FOLDER = "unarmed"
const ARMED_ATTACK_FOLDER = "fight"
const FLED_FOLDER = "fled"
const FAILURE_FOLDER = "lose"
const VICTORY_FOLDER = "win"
const POTION_DISCARD_FOLDER = "spill"
const HEAL_FOLDER = "heal"

# TODO: try loading a file with suit or rank info first
# emitted after dealing with card logic and game over checks, no conflict
func on_failure(_monster: CardData) -> void:
	portrait.try_load_random_image_from_subdir(FAILURE_FOLDER)

func on_fled() -> void:
	portrait.try_load_random_image_from_subdir(FLED_FOLDER)

# set portrait to 20.jpg or .png
func on_game_started() -> void:
	health_bar.change_value(20)
	portrait.try_load_numbered_image(20)

# caution: monster_killed and potion_used can also be emitted same time.
# make heal and fight images very narrow: Aces and face cards only, 8-10 hearts
# otherwise, show image if did unarmed attack or just update HP-based image
func on_health_changed(delta: int, was_unarmed_attack: bool, _card_data: CardData) -> void:
	var hp = health_bar.change_value(delta) # will not try to update the image
	var is_monster = _card_data.suit == CardData.Suit.CLUBS or _card_data.suit == CardData.Suit.SPADES
	var is_elite_monster = is_monster and _card_data.rank > 10
	var is_potent_heal = _card_data.suit == CardData.Suit.HEARTS and _card_data.rank > 7
	if was_unarmed_attack and portrait.try_load_random_image_from_subdir(UNARMED_ATTACK_FOLDER):
		return # if failed to load an image, I want to try the other cases
	elif is_elite_monster and not was_unarmed_attack and delta > -4 and portrait.try_load_random_image_from_subdir(ARMED_ATTACK_FOLDER):
		return # J-A killed with a strong weapon (via lost less than 4 health)
	elif is_potent_heal and portrait.try_load_random_image_from_subdir(HEAL_FOLDER):
		return # 8-10 value heal
	else:
		# cycle up from current hp to max looking for next valid image
		for i in range(hp, 21):
			if portrait.try_load_numbered_image(i):
				break

# happens instead of health_changed or potion_used, no conflict
func on_potion_discarded(_card_data: CardData) -> void:
	portrait.try_load_random_image_from_subdir(POTION_DISCARD_FOLDER)

# outsource to on_health_changed
func on_potion_used(_card_data: CardData) -> void:
	pass

# will hide images from every 3rd card used, ignore
func on_room_cleared() -> void:
	pass

# emitted after dealing with card logic and game over checks, no conflict
func on_victory() -> void:
	portrait.try_load_random_image_from_subdir(VICTORY_FOLDER)
