extends Control
class_name EmissaryAbilityUsesRemainingLabels

func set_labels(h: int, d: int, c: int, s: int) -> void:
	$HeartUses.text = str(h)
	$DiamondUses.text = str(d)
	$ClubUses.text = str(c)
	$SpadeUses.text = str(s)
