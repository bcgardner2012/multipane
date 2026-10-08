extends GamePane
class_name MrPresidentGamePane

signal round_end(winner: CardData, region: int)
signal game_over(winner: CardData.Suit)
