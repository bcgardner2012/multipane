extends HBoxContainer
class_name SandwichGuyHand


func _on_sandwich_guy_game_player_sandwich_served(sandwich: Array[CardData], _quality: int) -> void:
	for child in get_children():
		var highlighter = child as CardHighlighter
		highlighter._unhighlight()
		var card_node = child.get_child(0) as Card
		if card_node.data in sandwich:
			card_node.reset_texture_and_data()
