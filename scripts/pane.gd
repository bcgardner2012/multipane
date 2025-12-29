extends Control
class_name Pane

# 0 = hearts, 1 = diamonds, 2 = clubs, 3 = spades
var suit_channel: int

func _on_close_tool_gui_input(event: InputEvent) -> void:
	# close tool clicked, destroy pane
	if ClickHelper.is_left_click(event):
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
	elif from is Area52GamePane:
		var a52p = from as Area52GamePane
		a52p.aliens_drawn.connect($Area52GamePlug.on_aliens_drawn)
		a52p.defender_drawn.connect($Area52GamePlug.on_defender_drawn)
		a52p.dual_attack_performed.connect($Area52GamePlug.on_dual_attack_performed)
		a52p.sacrifice_performed.connect($Area52GamePlug.on_sacrifice_performed)
		a52p.single_attack_performed.connect($Area52GamePlug.on_single_attack_performed)
	elif from is SandwichGuyGamePane:
		var sggp = from as SandwichGuyGamePane
		sggp.sandwich_served.connect($SandwichGuyGamePlug.on_sandwich_served)
	elif from is EmissaryGamePane:
		var egp = from as EmissaryGamePane
		egp.advisor_consulted.connect($EmissaryGamePlug.on_advisor_consulted)
		egp.debate_started.connect($EmissaryGamePlug.on_debate_started)
		egp.lost_kingdom.connect($EmissaryGamePlug.on_lost_kingdom)
		egp.lost_topic.connect($EmissaryGamePlug.on_lost_topic)
		egp.won_game.connect($EmissaryGamePlug.on_won_game)
		egp.won_kingdom.connect($EmissaryGamePlug.on_won_kingdom)
		egp.won_topic.connect($EmissaryGamePlug.on_won_topic)

func _on_suit_icon_tune_suit_channel(channel: int) -> void:
	suit_channel = channel
