extends GamePane
class_name HorseRaceGamePane

signal race_started()
signal player_won(cash: int) # won the bet, pass wallet total
signal npc_won(npc: CardData.Suit, cash: int, player_cash: int) # implies player didn't win bet
signal moved(horse: CardData.Suit) # who won the race can be inferred by #emissions
