extends Control
class_name EmissaryPhaseInstructions


func _on_emissary_game_player_phase_changed(phase: EmissaryGamePlayer.Phase) -> void:
	for child in get_children():
		child.visible = false
	
	match phase:
		EmissaryGamePlayer.Phase.BetweenDebates:
			$ChooseKingdom.visible = true
		EmissaryGamePlayer.Phase.SeekingAdvice:
			$UseAbilityOrFlip.visible = true
		EmissaryGamePlayer.Phase.DiamondJackAwaiting:
			$ChooseTwoDiscard.visible = true
		EmissaryGamePlayer.Phase.SpadeJackAwaiting:
			$ChooseKingdomSwap.visible = true
		EmissaryGamePlayer.Phase.PlayerTurn:
			$PlayFromHand.visible = true
		EmissaryGamePlayer.Phase.GameOver:
			$GameOver.visible = true
