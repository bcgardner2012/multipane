extends TextureRect
class_name BackgroundImage

var home_dir: String
var current_dir: String

var image_paths: Array[String]
var index: int

func _ready() -> void:
	var dir = DirAccess.open("./backgrounds")
	home_dir = dir.get_current_dir()
	current_dir = home_dir
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with(".") or file_name.ends_with(".import"):
			file_name = dir.get_next()
			continue  # Skip hidden/system files.
		image_paths.append(home_dir.path_join(file_name))
		file_name = dir.get_next()
	
	index = 0
	_load_image(image_paths[index])

func _load_image(path: String) -> void:
	var img = Image.load_from_file(path)
	texture = ImageTexture.create_from_image(img)


func _on_change_background_button_pressed() -> void:
	index += 1
	index %= image_paths.size()
	_load_image(image_paths[index])
