extends HighLowGameAI
class_name HighLowWeightedRandomProbabilityAI

# If rank == 7, ~7/13 chance of saying LOW 

func generate_guess(prev_card: CardData, cur_card: CardData) -> HighLowPlayerControls.Guess:
	var r = (randi() % 13) + 1
	if r > cur_card.rank:
		return _finalize_answer(cur_card, HighLowPlayerControls.Guess.HIGH)
	else:
		return _finalize_answer(cur_card, HighLowPlayerControls.Guess.LOW)
