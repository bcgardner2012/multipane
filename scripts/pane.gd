extends Control
class_name Pane


func _on_close_tool_gui_input(event: InputEvent) -> void:
	# close tool clicked, destroy pane
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		queue_free()

func receive_broadcast(from: Node) -> void:
	if from is ScoundrelGamePane:
		var sgp = from as ScoundrelGamePane
		sgp.failure.connect($ScoundrelGamePlug.on_failure)
		sgp.fled.connect($ScoundrelGamePlug.on_fled)
		sgp.game_started.connect($ScoundrelGamePlug.on_game_started)
		sgp.health_changed.connect($ScoundrelGamePlug.on_health_changed)
		sgp.potion_discarded.connect($ScoundrelGamePlug.on_potion_discarded)
		sgp.potion_used.connect($ScoundrelGamePlug.on_potion_used)
		sgp.room_cleared.connect($ScoundrelGamePlug.on_room_cleared)
		sgp.victory.connect($ScoundrelGamePlug.on_victory)
