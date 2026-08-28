extends Node
class_name Area52GameAudio

@onready var is_mute: bool = false

func _on_area_52_game_player_dual_attack_performed(_humans: Array[CardData], _alien: CardData, _wave: int) -> void:
	_play_sound($GunshotSoundPlayer)

func _play_sound(sound: AudioStreamPlayer) -> void:
	if not is_mute:
		sound.play()


func _on_area_52_game_player_single_attack_performed(_human: CardData, _alien: CardData) -> void:
	_play_sound($GunshotSoundPlayer)


func _on_area_52_game_player_sacrifice_performed(_human: CardData, _alien: CardData, _replacement: CardData) -> void:
	_play_sound($SacrificeSoundPlayer)


func _on_area_52_game_player_game_over() -> void:
	_play_sound($LoseSoundPlayer)


func _on_area_52_game_player_game_won() -> void:
	_play_sound($WinSoundPlayer)


func _on_area_52_game_player_new_wave_incoming() -> void:
	_play_sound($ShuffleSoundPlayer)


func _on_sound_toggle_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		is_mute = !is_mute
