extends GamePane
class_name Area52GamePane

signal game_started()
signal dual_attack_performed(target: CardData)
signal single_attack_performed(target: CardData)
signal sacrifice_performed(target: CardData)
signal defender_drawn(deck_size: int)
signal aliens_drawn(aliens: Array[CardData])


func _on_area_52_game_player_dual_attack_performed(_humans: Array[CardData], alien: CardData, _wave: int) -> void:
	dual_attack_performed.emit(alien)


func _on_area_52_game_player_sacrifice_performed(_human: CardData, alien: CardData, _replacement: CardData) -> void:
	sacrifice_performed.emit(alien)


func _on_area_52_game_player_single_attack_performed(_human: CardData, alien: CardData) -> void:
	single_attack_performed.emit(alien)


func _on_deck_start_game() -> void:
	game_started.emit()


func _on_area_52_game_player_defender_drawn(deck_size: int) -> void:
	defender_drawn.emit(deck_size)


func _on_area_52_game_player_aliens_drawn(aliens: Array[CardData]) -> void:
	aliens_drawn.emit(aliens)
