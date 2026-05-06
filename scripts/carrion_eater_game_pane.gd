extends GamePane
class_name CarrionEaterGamePane

signal player_fell()
signal player_damaged(health: int)
signal player_attacked() # as in player did the attack
signal player_moved()
signal player_killed()
signal player_won()
signal enemy_killed()
signal enemy_respawned()
signal enemy_healed()
