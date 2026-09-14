extends ColorRect
class_name ThundercloudGameGraphic

var visible_children_count: int

# return true if 7th segment is shown
func show_next_segment() -> bool:
	visible_children_count += 1
	for i in range(visible_children_count):
		get_child(i).visible = true
	return visible_children_count >= 7
