extends TextureRect
class_name HealedStatusIndicator

func _turn_on(_card_data: CardData) -> void:
	visible = true

func _turn_off() -> void:
	visible = false
