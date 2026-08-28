extends Settings
class_name OutlawSettings

const MASS_EFFECT_THEME = 1

static var theme_mapping: Dictionary = {
	0: preload("res://assets/outlaw/outlaw_chart.jpg"),
	1: preload("res://assets/outlaw/me3_outlaw_chart.jpg"),
	2: preload("res://assets/outlaw/sonic_chart.jpg")
}

@export var chart: TextureRect

func _on_theme_option_button_item_selected(index: int) -> void:
	chart.texture = theme_mapping[index] as Texture2D
