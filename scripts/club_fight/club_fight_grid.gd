extends VBoxContainer
class_name ClubFightGrid

signal select_card(card: CardData, coordinates: Vector2i)
signal deselect_card(card: CardData, coordinates: Vector2i)

# grid: Array[Array[CardData]]
func show_grid(grid: Array) -> void:
	for i in range(0, 3):
		var row = get_child(i)
		for j in range(0, 3):
			var card_h = row.get_child(j) as CardHighlighter
			var card = card_h.get_child(0) as Card
			if grid[i][j] == null:
				card.reset_texture_and_data()
			else:
				card.set_card_data(grid[i][j])


func _on_card_use_card(data: CardData, button_index: int) -> void:
	var coordinates = get_coordinates(data)
	if button_index == MOUSE_BUTTON_LEFT:
		select_card.emit(data, coordinates)
	else:
		deselect_card.emit(data, coordinates)

# -1,-1 indicates an error, not found
func get_coordinates(data: CardData) -> Vector2i:
	for i in range(get_child_count()):
		var row = get_child(i)
		for j in range(row.get_child_count()):
			var card = row.get_child(j).get_child(0) as Card
			if card.data != null and card.data.equals(data):
				return Vector2i(i, j)
	return Vector2i(-1,-1)

func deselect() -> void:
	for row in get_children():
		for col in row.get_children():
			var card_h = col as CardHighlighter
			card_h._unhighlight()
