extends GamePane
class_name ScorpionTailGamePane

signal tail_grew(tail: Array[CardData])
signal tail_stung(tail: Array[CardData], was_player_stung: bool)
