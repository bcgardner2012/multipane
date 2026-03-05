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
	elif from is WarGamePane:
		var wgp = from as WarGamePane
		wgp.game_over.connect($WarGamePlug.on_game_over)
		wgp.game_started.connect($WarGamePlug.on_game_started)
		wgp.round_tied.connect($WarGamePlug.on_round_tied)
		wgp.round_won.connect($WarGamePlug.on_round_won)
	elif from is HighLowGamePane:
		var hlgp = from as HighLowGamePane
		hlgp.game_started.connect($HighLowGamePlug.on_game_started)
		hlgp.guessed_incorrectly.connect($HighLowGamePlug.on_guessed_incorrectly)
	elif from is BardsAndNoblesGamePane:
		var bnngp = from as BardsAndNoblesGamePane
		bnngp.customer_turned_away.connect($BardsAndNoblesGamePlug.on_customer_turned_away)
		bnngp.game_over.connect($BardsAndNoblesGamePlug.on_game_over)
		bnngp.game_started.connect($BardsAndNoblesGamePlug.on_game_started)
		bnngp.sale_made.connect($BardsAndNoblesGamePlug.on_sale_made)
	elif from is ZombieDiceGamePane:
		var zdgp = from as ZombieDiceGamePane
		zdgp.cards_drawn.connect($ZombieDiceGamePlug.on_cards_drawn)
		zdgp.round_won.connect($ZombieDiceGamePlug.on_round_won)
		zdgp.round_lost.connect($ZombieDiceGamePlug.on_round_lost)
	elif from is JokerJailbreakGamePane:
		var jjb = from as JokerJailbreakGamePane
		jjb.chipped.connect($JokerJailbreakGamePlug.on_chipped)
		jjb.game_won.connect($JokerJailbreakGamePlug.on_game_won)
	elif from is ScorpionTailGamePane:
		var stgp = from as ScorpionTailGamePane
		stgp.tail_grew.connect($ScorpionTailGamePlug.on_tail_grew)
		stgp.tail_stung.connect($ScorpionTailGamePlug.on_tail_stung)
	elif from is OutlawGamePane:
		var ogp = from as OutlawGamePane
		ogp.bounty_collected.connect($OutlawGamePlug.on_bounty_collected)
		ogp.outlaw_claimed.connect($OutlawGamePlug.on_outlaw_claimed)
		ogp.player_lost.connect($OutlawGamePlug.on_player_lost)
		ogp.player_won.connect($OutlawGamePlug.on_player_won)
	elif from is CardCaptureGamePane:
		var ccgp = from as CardCaptureGamePane
		ccgp.captured.connect($CardCaptureGamePlug.on_captured)
	elif from is OutrunGamePane:
		var ogp = from as OutrunGamePane
		ogp.attacked.connect($OutrunGamePlug.on_attacked)
		ogp.captured.connect($OutrunGamePlug.on_captured)
		ogp.game_started.connect($OutrunGamePlug.on_game_started)
	elif from is SnakeCharmerGamePane:
		var scgp = from as SnakeCharmerGamePane
		scgp.player_bit.connect($SnakeCharmerGamePlug.on_player_bit)
		scgp.player_lost.connect($SnakeCharmerGamePlug.on_player_lost)
		scgp.player_trying_to_capture.connect($SnakeCharmerGamePlug.on_player_attempting_to_capture)
		scgp.player_won.connect($SnakeCharmerGamePlug.on_player_won)
		scgp.player_rolled.connect($SnakeCharmerGamePlug.on_player_rolled)

func _on_suit_icon_tune_suit_channel(channel: int) -> void:
	suit_channel = channel
