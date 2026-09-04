extends GamePane
class_name ShadowSolitaireGamePane

signal player_won()
signal player_died()
signal bomb_used(target: CardData)
signal new_round_started(boss: CardData, health: int)
signal attacked(target: CardData, action: CardData, healths: Array[int])
signal grapple_attacked(targets: Array[CardData], action: CardData)
signal joker_drawn()
