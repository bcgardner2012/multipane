extends HighLowGameAI
class_name HighLowSimpleProbabilityAI

# If rank < 7, HIGH, else LOW

func generate_guess(prev_card: CardData, cur_card: CardData) -> HighLowPlayerControls.Guess:
	if cur_card.rank < 7:
		return HighLowPlayerControls.Guess.HIGH
	else:
		return HighLowPlayerControls.Guess.LOW
