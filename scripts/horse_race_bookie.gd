extends ColorRect
class_name HorseRaceBookie

func update_cash_totals(totals: Array[int]) -> void:
	for i in range(0, totals.size()):
		# account for Background and Headers...
		var total_label = get_child(i+2).get_child(0).get_child(0) as Label
		total_label.text = "$" + str(totals[i])
