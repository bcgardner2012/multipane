extends GamePane
class_name BeetleGamePane

signal part_added(index: int) # player 0-2, plugs will track how many parts
signal game_over(winner: int)
