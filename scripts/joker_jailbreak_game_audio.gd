extends Node
class_name JokerJailbreakGameAudio

var is_mute: bool

func _on_sound_toggle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_mute = !is_mute

func _play_sound(sound: AudioStreamPlayer) -> void:
	if not is_mute:
		sound.play()


func _on_joker_jailbreak_game_player_selection_confirmed() -> void:
	_play_sound($PickaxeSoundPlayer)


func _on_joker_jailbreak_game_player_game_won() -> void:
	_play_sound($GameWonSoundPlayer)
