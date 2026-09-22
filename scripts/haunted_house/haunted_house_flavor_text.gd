extends Label
class_name HauntedHouseFlavorText


func _on_show_text(_text: String, color: Color) -> void:
	text = _text
	label_settings.font_color = color
