extends GamePane
class_name HorseRaceGamePane

signal race_started()
signal player_won(cash: int) # won the bet, pass wallet total
signal npc_won(npc: CardData.Suit, cash: int)
signal moved(horse: CardData.Suit) # who won the race can be inferred by #emissions
