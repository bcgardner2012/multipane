extends GamePane
class_name EmissaryGamePane

signal won_topic(kingdom: CardData, winning_card: CardData)
signal lost_topic(kingdom: CardData, losing_card: CardData)
signal won_kingdom(kingdom: CardData)
signal lost_kingdom(kingdom: CardData) # and therefore, lost the game
signal debate_started(kingdom: CardData)
signal advisor_consulted(suit: CardData.Suit)
signal won_game(last_kingdom: CardData)

var kingdoms_won: int

func _on_emissary_game_player_debate_started(kingdom: CardData, _drawn_card: CardData) -> void:
	debate_started.emit(kingdom)


func _on_emissary_game_player_heart_advisor_used(_to_remove: Array[CardData]) -> void:
	advisor_consulted.emit(CardData.Suit.HEARTS)


func _on_emissary_game_player_club_advisor_used(_drawn_cards: Array[CardData]) -> void:
	advisor_consulted.emit(CardData.Suit.CLUBS)


func _on_emissary_game_player_diamond_advisor_used(_drawn_cards: Array[CardData]) -> void:
	advisor_consulted.emit(CardData.Suit.DIAMONDS)


func _on_emissary_game_player_spade_advisor_used(_prev: CardData, _next: CardData) -> void:
	advisor_consulted.emit(CardData.Suit.SPADES)


func _on_emissary_game_player_externalize_card_play(kingdom: CardData, won: bool, card: CardData) -> void:
	if won:
		won_topic.emit(kingdom, card)
	else:
		lost_topic.emit(kingdom, card)


func _on_emissary_game_player_kingdom_won(kingdom: CardData) -> void:
	kingdoms_won += 1
	if kingdoms_won == 8:
		won_game.emit(kingdom)
	else:
		won_kingdom.emit(kingdom)


func _on_emissary_game_player_game_lost(kingdom: CardData) -> void:
	lost_kingdom.emit(kingdom)
