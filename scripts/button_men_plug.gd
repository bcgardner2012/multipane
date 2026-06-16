extends Node
class_name ButtonMenPlug

@export var fullscreen_pane: Control
@export var duo_pane: Control

var fullscreen_port: Portrait
var left_port: Portrait
var right_port: Portrait

const E_CHAR_SELECT = "E_CHAR_SELECT"
const E_CHAR_REMOVE = "E_CHAR_REMOVE"
const E_ATTACK = "attack"
const E_TAG = "tag"
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

# portrait logic looks at ./portraits, and appends suffixes
const PATH_PREFIX = "buttonmen"

const P1 = 1
const P2 = 2

var _first_frame: bool = true
# path prefix + character name
var _p1_path: String
var _p2_path: String
var _t1_path: String
var _t2_path: String

# just the character name
var _p1_name: String = ''
var _p2_name: String = ''
var _t1_name: String = ''
var _t2_name: String = ''

# in tag matches, who is active?
var _active_p1_character: String
var _active_p2_character: String
var _active_p1_path: String
var _active_p2_path: String

func _process(_delta: float) -> void:
	if _first_frame:
		_first_frame = false
		fullscreen_port = fullscreen_pane.get_child(0).get_child(0)
		left_port = duo_pane.get_child(0).get_child(0)
		right_port = duo_pane.get_child(1).get_child(0)

# TODO: tournament setup
func on_message_received(msg) -> void:
	var event_name: String = msg.event_name
	var _path = PATH_PREFIX
	match event_name:
		E_CHAR_REMOVE:
			if _t2_name != '':
				_t2_name = ''
				_t2_path = ''
			elif _p2_name != '':
				_p2_name = ''
				_p2_path = ''
			elif _t1_name != '':
				_t1_name = ''
				_t1_path = ''
			elif _p1_name != '':
				_p1_name = ''
				_p1_path = ''
			pass
		E_CHAR_SELECT:
			_path = _path.path_join(msg.character_name)
			if msg.player == P1:
				left_port.try_load_image(_path.path_join("profile"))
				if _p1_name != '':
					_t1_path = _path
					_t1_name = msg.character_name
				else:
					_p1_path = _path
					_p1_name = msg.character_name
					_active_p1_character = _p1_name
			else:
				right_port.try_load_image(_path.path_join("profile"))
				if _p2_name != '':
					_t2_path = _path
					_t2_name = msg.character_name
				else:
					_p2_path = _path
					_p2_name = msg.character_name
					_active_p2_character = _p2_name
			_show_duo_panes()
		E_ATTACK:
			var _attack_type = _int_to_attack_type(msg.attack_type)
			if msg.player == P1:
				# Damage dealt by P1, taken by P2
				_show_duo_panes_attack(_attack_type, ATTACK_SUBDIR, DAMAGE_SUBDIR)
			else:
				# Damage dealt by P2, taken by P1
				_show_duo_panes_attack(_attack_type, DAMAGE_SUBDIR, ATTACK_SUBDIR)
		E_TAG:
			if msg.player == P1:
				if _active_p1_character == _p1_name:
					_active_p1_character = _t1_name
					_active_p1_path = _t1_path
				else:
					_active_p1_character = _p1_name
					_active_p1_path = _p1_path
			else:
				if _active_p2_character == _p2_name:
					_active_p2_character = _t2_name
					_active_p2_path = _t2_path
				else:
					_active_p2_character = _p2_name
					_active_p2_path = _p2_path
		E_ROUND_END:
			_show_fullscreen_pane_ending(msg, ROUND_WON_SUBDIR, ROUND_LOST_SUBDIR)
		E_GAME_END:
			_show_fullscreen_pane_ending(msg, GAME_WON_SUBDIR, GAME_LOST_SUBDIR)

func _show_fullscreen_pane() -> void:
	duo_pane.visible = false
	fullscreen_pane.visible = true

func _show_duo_panes() -> void:
	duo_pane.visible = true
	fullscreen_pane.visible = false

func _show_duo_panes_attack(attack_type: String, p1_subdir: String, p2_subdir: String) -> void:
	_show_duo_panes()
	
	var _path = _active_p1_path.path_join(p1_subdir)
	if not left_port.try_load_random_image_from_subdir(_path.path_join(attack_type)):
		left_port.try_load_random_image_from_subdir(_path)
	
	_path = _active_p2_path.path_join(p2_subdir)
	if not right_port.try_load_random_image_from_subdir(_path.path_join(attack_type)):
		right_port.try_load_random_image_from_subdir(_path)

func _show_fullscreen_pane_ending(msg, won_subdir: String, lost_subdir: String) -> void:
	var _path: String
	if msg.winner == P1:
		_path = _active_p1_path.path_join(won_subdir)
	else:
		_path = _active_p1_path.path_join(lost_subdir)
	
	# /p1name/w|l/p2name/randomimg
	var loaded = fullscreen_port.try_load_random_image_from_subdir(_path.path_join(_active_p2_character))
	if not loaded:
		# /p1name/w|l
		loaded = fullscreen_port.try_load_random_image_from_subdir(_path)
	if not loaded:
		# /p2name/w|l/p1name/randomimg
		if msg.winner == P1:
			_path = _active_p2_path.path_join(lost_subdir)
		else:
			_path = _active_p2_path.path_join(won_subdir)
		loaded = fullscreen_port.try_load_random_image_from_subdir(_path.path_join(_active_p1_character))
	if not loaded:
		# /p2name/w|l
		fullscreen_port.try_load_random_image_from_subdir(_path)
	_show_fullscreen_pane()

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
