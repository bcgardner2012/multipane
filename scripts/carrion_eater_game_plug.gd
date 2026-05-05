extends GamePlug
class_name CarrionEaterGamePlug

# How should this one be organized?
# Enemy and player events happen at different points. One pane may be enough.
# Move and attack are on separate commands. Taking damage and enemy healing
# is on reroll

# Where is the overlap that could prevent images from showing?
# On reroll mainly: enemy heal, enemy respawn, and player take dmg
# Sort of on attack: player attack, enemy killed (latter should take priority)

# Improvements:
# Include enemy index. Which enemy healed, and have images unique to that index
# Include amount of damage player took. More damage shows more severe images.
# Track how many times in a row player moved. More points spent on movement
# could show more "heroic" flight images (taking off, floating, superman pose)
# Track direction of movement. Move down could show hero-landing.
# Include number of action dice. There are underbelly riding images.
# Include player health. Movement could reflect some sort of transformation.

const PLAYER_MOVED_DIR = "player_moved"
const PLAYER_DAMAGED_DIR = "player_damage"
const PLAYER_ATTACK_DIR = "player_attack"

var health: int = 6

func on_enemy_healed() -> void:
	portrait.try_load_random_image_from_subdir("enemy_healed")

func on_enemy_killed() -> void:
	portrait.try_load_random_image_from_subdir("enemy_killed")

func on_enemy_respawned() -> void:
	portrait.try_load_random_image_from_subdir("enemy_respawn")
	
func on_player_attacked() -> void:
	var dir = PLAYER_ATTACK_DIR + "/" + str(health)
	if !portrait.try_load_random_image_from_subdir(dir):
		portrait.try_load_random_image_from_subdir(PLAYER_ATTACK_DIR)

func on_player_damaged(_health: int) -> void:
	self.health = _health
	var dir = PLAYER_DAMAGED_DIR + "/" + str(health)
	if !portrait.try_load_random_image_from_subdir(dir):
		portrait.try_load_random_image_from_subdir(PLAYER_DAMAGED_DIR)

func on_player_killed() -> void:
	portrait.try_load_random_image_from_subdir("player_killed")

# load a subdir based on health and select a random image there, fallback to 
# parent dir
func on_player_moved() -> void:
	var dir = PLAYER_MOVED_DIR + "/" + str(health)
	if !portrait.try_load_random_image_from_subdir(dir):
		portrait.try_load_random_image_from_subdir(PLAYER_MOVED_DIR)

func on_player_won() -> void:
	portrait.try_load_random_image_from_subdir("player_won")
