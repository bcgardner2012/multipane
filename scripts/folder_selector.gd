extends OptionButton
class_name FolderSelector

var home_dir: String
var current_dir: String

signal image_selected(path: String)
signal dir_changed(dir: String)

func _ready() -> void:
	var dir = DirAccess.open("./portraits")
	home_dir = dir.get_current_dir()
	current_dir = home_dir
	_populate_items()

func _populate_items() -> void:
	var dir = DirAccess.open(current_dir)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	add_item("")
	if current_dir != home_dir:
		add_item("..")
	while file_name != "":
		if file_name.begins_with(".") or file_name.ends_with(".import"):
			file_name = dir.get_next()
			continue  # Skip hidden/system files. Godot also tries to import image files, creating another file
		add_item(file_name)
		file_name = dir.get_next()


func _on_item_selected(index: int) -> void:
	var itemText = get_item_text(index)
	
	if itemText == "..":
		# go back
		var last_slash_index = current_dir.rfind("/")
		current_dir = current_dir.substr(0, last_slash_index)
		clear()
		_populate_items()
		dir_changed.emit(current_dir)
	elif itemText == "":
		# selected the default value, do nothing
		return
	else:
		# got a file name, check for dir or image
		var path = current_dir.path_join(itemText)
		var dir = DirAccess.open(path)
		if dir:
			# file is a directory
			current_dir = path
			clear()
			_populate_items()
			dir_changed.emit(current_dir)
		elif _has_image_extension(path):
			# fire event, update Portrait node
			image_selected.emit(path)

func _has_image_extension(path: String) -> bool:
	return path.ends_with(".jpg") or path.ends_with(".png") or path.ends_with(".jpeg")


func _on_random_image_button_pressed() -> void:
	var imageIndexes: Array[int] = []
	for i in range(item_count):
		var item = get_item_text(i)
		if item.ends_with(".jpg") or item.ends_with(".png"):
			imageIndexes.append(i)
	
	if imageIndexes.size() == 0:
		return
	var r = randi() % imageIndexes.size()
	select(imageIndexes[r])
	image_selected.emit(current_dir.path_join(get_item_text(imageIndexes[r])))
