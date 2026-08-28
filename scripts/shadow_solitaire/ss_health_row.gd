extends HBoxContainer
class_name SSHealthRow

# add a space on either side of numbers to keep alignment closer to center
func show_health(health: Array[int]) -> void:
	for i in range(0, mini(health.size(), 6)):
		var label = get_child(i) as Label
		label.visible = true
		label.text = " " + str(health[i]) + " "
		
	for i in range(health.size(), get_child_count()):
		get_child(i).visible = false
