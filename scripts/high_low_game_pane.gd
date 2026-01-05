extends GamePane
class_name HighLowGamePane

# I want images to work similarly to dropping health as players guess wrong
signal guessed_incorrectly(suit_channel: int, was_same: bool)
signal game_started()
