extends GamePane
class_name OutrunGamePane

signal game_started()
# 0 for red, 1 for blue, 2 for green
signal attacked(index: int)
signal captured(index: int)
