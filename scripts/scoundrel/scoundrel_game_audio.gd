extends Node
class_name ScoundrelGameAudio

@onready var is_mute: bool = false

func _on_scoundrel_game_potion_used(_card_data: CardData) -> void:
	_play_sound($DrinkSoundPlayer)

func _on_scoundrel_game_room_cleared() -> void:
	_play_sound($DoorSoundPlayer)

func _on_scoundrel_game_potion_discarded(_card_data: CardData) -> void:
	_play_sound($SpillSoundPlayer)

func _on_scoundrel_game_weapon_equipped(_card_data: CardData) -> void:
	_play_sound($EquipSoundPlayer)

func _on_scoundrel_game_monster_killed(_card_data: CardData) -> void:
	_play_sound($SwingSoundPlayer)

func _on_scoundrel_game_fled() -> void:
	_play_sound($DoorSoundPlayer)

func _on_scoundrel_game_victory() -> void:
	_play_sound($WinSoundPlayer)

func _on_scoundrel_game_failure(_monster: CardData) -> void:
	_play_sound($LoseSoundPlayer)

func _on_scoundrel_game_game_started() -> void:
	_play_sound($ShuffleSoundPlayer)


func _on_sound_toggle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_mute = !is_mute

func _play_sound(sound: AudioStreamPlayer) -> void:
	if not is_mute:
		sound.play()
