extends HighLowGameAI
class_name HighLowCardCounterAI

# Knows there are 4 of each rank. Decreases count based on cur_card.
# Sums all those >= cur_card, and separately those <, and uses that
# diff to say HIGH or LOW

var card_counts = [
	4, 4, 4, 4,
	4, 4, 4, 4, 
	4, 4, 4, 4, 4
]

func generate_guess(prev_card: CardData, cur_card: CardData) -> HighLowPlayerControls.Guess:
	var index = cur_card.rank - 1
	card_counts[index] -= 1
	
	var high_score = 0
	for i in range(index, 13):
		high_score += card_counts[i]
	
	var low_score = 0
	for i in range(0, index):
		low_score += card_counts[i]
	
	if high_score >= low_score:
		return _finalize_answer(cur_card, HighLowPlayerControls.Guess.HIGH)
	else:
		return _finalize_answer(cur_card, HighLowPlayerControls.Guess.LOW)
