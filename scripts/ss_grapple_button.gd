extends TextureButton
class_name SSGrappleButton

signal grapple_clicked(card1: CardData, card2: CardData)

@export var left_card: Card
@export var right_card: Card

func _on_pressed() -> void:
	grapple_clicked.emit(left_card.data, right_card.data)
