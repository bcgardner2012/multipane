extends GamePane
class_name ShadowSolitaireGamePane

signal player_won()
signal player_died()
signal bomb_used()
signal new_round_started(boss: CardData, health: int)
signal attacked(target: CardData, action: CardData)
signal joker_drawn()
