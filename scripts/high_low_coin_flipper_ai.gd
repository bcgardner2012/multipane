extends HighLowGameAI
class_name HighLowCoinFlipperAI

func generate_guess(prev_card: CardData, cur_card: CardData) -> HighLowPlayerControls.Guess:
	var r = randi() % 2
	if r == 0:
		return _finalize_answer(cur_card, HighLowPlayerControls.Guess.HIGH)
	else:
		return _finalize_answer(cur_card, HighLowPlayerControls.Guess.LOW)
