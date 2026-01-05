extends HighLowGameAI
class_name HighLowSamesiesAI

# looks at the last correct answer and assumes that will happen again

var memorized_card: CardData

func generate_guess(prev_card: CardData, cur_card: CardData) -> HighLowPlayerControls.Guess:
	if prev_card == null:
		# first card
		memorized_card = cur_card
		_finalize_answer(cur_card, HighLowPlayerControls.Guess.HIGH)
	
	if prev_card == memorized_card:
		# second card
		return _finalize_answer(cur_card, HighLowPlayerControls.Guess.HIGH)
	
	if prev_card != null:
		var last_correct_answer = HighLowPlayerControls.Guess.LOW
		if memorized_card.rank < prev_card.rank: # went up
			last_correct_answer = HighLowPlayerControls.Guess.HIGH
		
		# I'm done with the memorized card
		# this prev_card is about to leave play, memorize it
		memorized_card = prev_card
		return _finalize_answer(cur_card, last_correct_answer)
	
	return _finalize_answer(cur_card, HighLowPlayerControls.Guess.HIGH)
