extends Node
class_name SandwichGuyGameAudio


@onready var is_mute: bool = false

func _play_sound(sound: AudioStreamPlayer) -> void:
	if not is_mute:
		sound.play()

func _on_sandwich_guy_game_player_sandwich_served(_sandwich: Array[CardData], _quality: int) -> void:
	_play_sound($CashRegisterSoundPlayer)


func _on_sound_toggle_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		is_mute = !is_mute
