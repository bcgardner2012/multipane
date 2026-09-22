extends HBoxContainer
class_name HauntedHouseItems

var items: Array[HauntedHouseGamePlayer.Item]

func show_item(item: HauntedHouseGamePlayer.Item) -> void:
	if not item in items:
		items.append(item)
	
	match item:
		HauntedHouseGamePlayer.Item.CANDLE:
			$Candle.visible = true
		HauntedHouseGamePlayer.Item.SPRAY:
			$Spray.visible = true
		HauntedHouseGamePlayer.Item.HOLY_WATER:
			$"Holy Water".visible = true
		HauntedHouseGamePlayer.Item.FLASHLIGHT:
			$Flashlight.visible = true

func hide_item(item: HauntedHouseGamePlayer.Item) -> void:
	var i = items.find(item)
	if i > -1:
		items.remove_at(i)
	
	match item:
		HauntedHouseGamePlayer.Item.CANDLE:
			$Candle.visible = false
		HauntedHouseGamePlayer.Item.SPRAY:
			$Spray.visible = false
		HauntedHouseGamePlayer.Item.HOLY_WATER:
			$"Holy Water".visible = false
		HauntedHouseGamePlayer.Item.FLASHLIGHT:
			$Flashlight.visible = false

func hide_all() -> void:
	items = []
	for child in get_children():
		child.visible = false
