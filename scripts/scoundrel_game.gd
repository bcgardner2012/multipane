extends Control
class_name ScoundrelGamePane

# we can define signals that need to be connected to other panes here.
# the game player can emit these signals, but they do need to be defined here.

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


func _on_close_tool_gui_input(event: InputEvent) -> void:
	# close tool clicked, destroy pane
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		queue_free()
