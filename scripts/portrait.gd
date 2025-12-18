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
	var path = current_dir.path_join(str(value) + ".png")
	var file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		_load_image(path)
		file.close()
		return
	
	path = current_dir.path_join(str(value) + ".jpg")
	file = FileAccess.open(path, FileAccess.READ)
	if file != null:
		_load_image(path)
		file.close()
		return

func _on_folder_selector_dir_changed(dir: String) -> void:
	current_dir = dir

func _load_image(path: String) -> void:
	var img = Image.load_from_file(path)
	texture = ImageTexture.create_from_image(img)
