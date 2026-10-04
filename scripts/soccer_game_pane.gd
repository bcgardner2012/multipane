extends GamePane
class_name SoccerGamePane

signal kicked(card: CardData) # the card that won a comparison
signal goal(card: CardData) # the card that kicked into the goal
signal game_won()
signal game_lost()
signal game_tied()
