extends TextEdit
class_name HorseRaceBetTextEdit

signal bet_set(bet: int)

var prev_text: String

func _on_text_changed() -> void:
	var bet = int(text)
	if bet == 0:
		if text != "":
			text = prev_text
	else:
		prev_text = text
		bet_set.emit(bet)


func _on_horse_race_game_player_race_started() -> void:
	editable = false


func _on_horse_race_game_player_race_ended(_winner: CardData.Suit) -> void:
	editable = true
	text = ""
