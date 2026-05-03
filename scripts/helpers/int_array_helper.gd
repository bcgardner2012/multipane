extends Node
class_name IntArrayHelper

static func contains(arr: Array[int], x: int) -> bool:
	for i in arr:
		if i == x:
			return true
	return false

# does nothing if x is not found
static func remove(arr: Array[int], x: int) -> void:
	var i = arr.find(x)
	if i != -1:
		arr.remove_at(arr.find(x))

# to_rem is generic Array specifically to support range() function
static func remove_range(arr: Array[int], to_rem: Array) -> void:
	for i in to_rem:
		remove(arr, i as int)

# much simpler to just build a new array and return it
static func dedupe(arr: Array[int]) -> Array[int]:
	var _arr: Array[int] = []
	for i in arr:
		if not contains(_arr, i):
			_arr.append(i)
	return _arr
