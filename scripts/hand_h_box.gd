extends Control
class_name HandHBox

# Maintains its current size as the maximum and arranges children
# evenly within, centered horizontally, allowing overlap.

var _last_known_dimensions: Vector2

func _process(_delta: float) -> void:
	if (_last_known_dimensions != size):
		_last_known_dimensions = size
		_readjust()

func _on_child_entered_tree(_node: Node) -> void:
	_readjust()
	
func _readjust() -> void:
	# adjust all children to evenly distribute horizontally
	var self_width = self.size.x
	var half_self_width = self_width / 2
	var chunk_width = self_width / get_child_count()
	var half_chunk_width = chunk_width / 2
	var i = 0
	for child in get_children():
		var child_control = child as Control
		var half_child_width = child_control.size.x / 2
		child_control.set_anchors_preset(Control.PRESET_CENTER)
		
		# divide self width into n chunks of equal width
		# card centers must align with the half-way point of their chunk
		# first, stack all cards, centered on the left border
		child_control.offset_left = 0 - half_self_width - half_child_width
		child_control.offset_right = 0 - half_self_width + half_child_width
		# second, move each to a point, x chunks over, halfway into the next
		var delta = (chunk_width * i) + half_chunk_width
		child_control.offset_right += delta
		child_control.offset_left += delta
		
		i += 1


func _on_child_order_changed() -> void:
	_readjust()
