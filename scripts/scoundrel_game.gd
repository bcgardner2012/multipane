extends GamePane
class_name ScoundrelGamePane

# we can define signals that need to be connected to other panes here.
# the game player can emit these signals, but they do need to be defined here.
# Emit more specific signals later (ie, potion_used more specific than health_changed)

signal game_started()
signal health_changed(delta: int, was_unarmed_attack: bool, card_data: CardData)
signal weapon_equipped(card_data: CardData)
signal monster_killed(card_data: CardData)
signal victory() # pass score?
signal failure(monster: CardData) # pass the monster that killed us
signal fled() # pass the cards skipped?
signal potion_discarded(card_data: CardData) # if we implement the 1 potion per room rule... 
signal potion_used(card_data: CardData)
signal room_cleared()
