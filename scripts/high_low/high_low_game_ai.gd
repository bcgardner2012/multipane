extends Node
class_name HighLowGameAI

func _ready() -> void:
	randomize()

# You need to override this
func generate_guess(prev_card: CardData, cur_card: CardData) -> HighLowPlayerControls.Guess:
	return HighLowPlayerControls.Guess.HIGH

# add simple checks here, like rank == 1... answer must be high, you're retarded otherwise
func _finalize_answer(cur_card: CardData, cur_guess: HighLowPlayerControls.Guess) -> HighLowPlayerControls.Guess:
	if cur_card.rank == 1:
		return HighLowPlayerControls.Guess.HIGH
	elif cur_card.rank == 13:
		return HighLowPlayerControls.Guess.LOW
	return cur_guess
