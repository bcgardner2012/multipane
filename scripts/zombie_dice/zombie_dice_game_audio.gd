extends Node
class_name ZombieDiceGameAudio

var is_mute: bool

func _on_sound_toggle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_mute = !is_mute

func _play_sound(sound: AudioStreamPlayer) -> void:
	if not is_mute:
		sound.play()


func _on_zombie_dice_game_player_hit_three_times() -> void:
	_play_sound($GunshotSoundPlayer)


func _on_draw_again_button_pressed() -> void:
	_play_sound($ZombieBiteSoundPlayer)


func _on_stop_button_pressed() -> void:
	_play_sound($DoorSoundPlayer)


func _on_human_deck_start_game() -> void:
	_play_sound($DoorSoundPlayer)
