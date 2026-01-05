extends HighLowGameAI
class_name HighLowOpposittorAI

# remembers the last correct answer (High or low) and will guess the
# opposite of that

var memorized_card: CardData

func generate_guess(prev_card: CardData, cur_card: CardData) -> HighLowPlayerControls.Guess:
	if prev_card == null:
		# first card
		memorized_card = cur_card
		return _finalize_answer(cur_card, HighLowPlayerControls.Guess.HIGH)
	
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
		
		if last_correct_answer == HighLowPlayerControls.Guess.LOW:
			return _finalize_answer(cur_card, HighLowPlayerControls.Guess.HIGH)
		else:
			return _finalize_answer(cur_card, HighLowPlayerControls.Guess.LOW)
	
	return _finalize_answer(cur_card, HighLowPlayerControls.Guess.HIGH)
