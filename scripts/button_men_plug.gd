extends Node
class_name ButtonMenPlug

@export var portrait: Portrait

const E_CHAR_SELECT = "E_CHAR_SELECT"
const E_ATTACK = "attack"
const E_ROUND_END = "round_end"
const E_GAME_END = "game_end"

const ATTACK_SUBDIR = "attack"
const DAMAGE_SUBDIR = "damage"
const POWER_SUBDIR = "power"
const SKILL_SUBDIR = "skill"
const SHADOW_SUBDIR = "shadow"
const RUSH_SUBDIR = "rush"

const ROUND_WON_SUBDIR = "round_won"
const ROUND_LOST_SUBDIR = "round_lost"
const GAME_WON_SUBDIR = "game_won"
const GAME_LOST_SUBDIR = "game_lost"

var player: int = 0
var character_name: String
var path: String


func on_message_received(msg) -> void:
	if player == 0:
		# assume we're only loading in server panes
		player = get_parent().get_parent().get_index() + 1
	
	var event_name: String = msg.event_name
	var _path: String
	match event_name:
		E_CHAR_SELECT:
			if msg.player == player:
				character_name = msg.character_name
				path = character_name
				portrait.try_load_image(path.path_join("profile"))
		E_ATTACK:
			var _attack_type = _int_to_attack_type(msg.attack_type)
			if msg.player == player:
				# Damage dealt
				_path = path.path_join(ATTACK_SUBDIR)
			else:
				# Damage taken
				_path = path.path_join(DAMAGE_SUBDIR)
			if not portrait.try_load_random_image_from_subdir(_path.path_join(_attack_type)):
				portrait.try_load_random_image_from_subdir(_path)
		E_ROUND_END:
			# Ties are possible, ignoring those
			if msg.winner == player:
				_path = path.path_join(ROUND_WON_SUBDIR)
			else:
				_path = path.path_join(ROUND_LOST_SUBDIR)
			portrait.try_load_random_image_from_subdir(_path)
		E_GAME_END:
			if msg.winner == player:
				_path = path.path_join(GAME_WON_SUBDIR)
			else:
				_path = path.path_join(GAME_LOST_SUBDIR)
			portrait.try_load_random_image_from_subdir(_path)

func _int_to_attack_type(i: int) -> String:
	match i:
		1:
			return POWER_SUBDIR
		2:
			return SKILL_SUBDIR
		3:
			return SHADOW_SUBDIR
		4:
			return RUSH_SUBDIR
	return ""
