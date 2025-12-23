extends TextureRect
class_name Portrait

var current_dir: String

func _ready() -> void:
	var dir = DirAccess.open("./portraits")
	current_dir = dir.get_current_dir()

func _on_folder_selector_image_selected(path: String) -> void:
	_load_image(path)

# allows image toggling by gauge value. Only .png and .jpg extensions supported.
func _on_label_gauge_value_changed(value: int) -> void:
	try_load_numbered_image(value)

# returns true if successfully loaded an image, false otherwise
func try_load_numbered_image(value: int) -> bool:
	return try_load_image(str(value) + ".png") or try_load_image(str(value) + ".jpg")

func try_load_numbered_image_from_subdir(value: int, subdir: String) -> bool:
	var suffix = subdir.path_join(str(value))
	return try_load_image(suffix + ".png") or try_load_image(suffix + ".jpg")

func try_load_random_image_from_subdir(subdir: String) -> bool:
	var path = current_dir.path_join(subdir)
	var dir = DirAccess.open(path)
	if dir == null:
		return false
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var imgs = []
	while file_name != "":
		if file_name.begins_with(".") or file_name.ends_with(".import"):
			file_name = dir.get_next()
			continue  # Skip hidden/system files. Godot also tries to import image files, creating another file
		imgs.append(file_name)
		file_name = dir.get_next()
	
	if imgs.size() <= 0:
		return false
	var r = randi() % imgs.size()
	var img = imgs[r]
	return try_load_image(subdir.path_join(img))

func try_load_image(suffix: String) -> bool:
	var path = current_dir.path_join(suffix)
	var file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		_load_image(path)
		file.close()
		return true
	return false

func _on_folder_selector_dir_changed(dir: String) -> void:
	current_dir = dir

func _load_image(path: String) -> void:
	var img = Image.load_from_file(path)
	texture = ImageTexture.create_from_image(img)
