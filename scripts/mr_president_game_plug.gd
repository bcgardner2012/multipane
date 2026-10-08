extends GamePlug
class_name MrPresidentGamePlug

# Idea: players are competing for votes. I can imagine updating imgs based on
# who won a round or the game. Since scores are updated every round, there are
# likely frequent conflicts between img events when based on score.

const SUIT_TO_STR = {
	CardData.Suit.HEARTS: "heart",
	CardData.Suit.DIAMONDS: "diamond",
	CardData.Suit.SPADES: "spade",
	CardData.Suit.CLUBS: "tie"
}

func on_round_end(winner: CardData, region: int) -> void:
	var ws = SUIT_TO_STR[winner.suit]
	if not portrait.try_load_random_image_from_subdir(ws.path_join(str(region))):
		portrait.try_load_random_image_from_subdir(ws)

func on_game_over(winner: CardData.Suit) -> void:
	portrait.try_load_random_image_from_subdir("win".path_join(SUIT_TO_STR[winner]))
