extends Node
class_name CardDataArrayHelper

static func cast_to_card_data_array(arr: Array) -> Array[CardData]:
	var t: Array[CardData] = []
	for a in arr:
		t.append(a as CardData)
	return t
