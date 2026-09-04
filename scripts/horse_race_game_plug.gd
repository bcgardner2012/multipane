extends GamePlug
class_name HorseRaceGamePlug

func on_moved(horse: CardData.Suit) -> void:
	pass

func on_player_won(cash: int) -> void:
	pass

func on_npc_won(npc: CardData.Suit, cash: int) -> void:
	pass

# clear data
func on_race_started() -> void:
	pass
