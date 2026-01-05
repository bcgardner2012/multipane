extends Node
class_name BardsAndNoblesGameAudio

@onready var is_mute: bool = false

func _on_sound_toggle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_mute = !is_mute

func _play_sound(sound: AudioStreamPlayer) -> void:
	if not is_mute:
		sound.play()


func _on_bards_and_nobles_game_sale_made(_customer: CardData, _trade_in: CardData, _standing_gain: int) -> void:
	_play_sound($CashRegisterSoundPlayer)


func _on_bards_and_nobles_game_game_over(score: int) -> void:
	if score >= 7:
		# win
		_play_sound($WinSoundPlayer)
	else:
		# lose
		_play_sound($LoseSoundPlayer)
