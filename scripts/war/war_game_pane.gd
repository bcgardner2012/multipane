extends GamePane
class_name WarGamePane

signal game_started()
signal game_over(red_score: int, blue_score: int)
signal round_won(did_red_win: bool, red_score: int, blue_score: int)
signal round_tied(red_score: int, blue_score: int)
