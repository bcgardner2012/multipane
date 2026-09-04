extends TextureRect
class_name HorseRaceSuitSelector

signal suit_selected(suit: CardData.Suit)

@export var textures: Array[Texture2D]
@export var suits: Array[CardData.Suit]

var index: int
var race_started: bool

func _on_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event) and not race_started:
		index += 1
		index %= textures.size()
		texture = textures[index]
		suit_selected.emit(suits[index])


func _on_horse_race_game_player_race_started() -> void:
	race_started = true


func _on_horse_race_game_player_race_ended(_winner: CardData.Suit) -> void:
	race_started = false
