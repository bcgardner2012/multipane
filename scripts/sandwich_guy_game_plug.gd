extends GamePlug
class_name SandwichGuyGamePlug

# load 0.jpg, 1.jpg or 2.jpg based on quality
func on_sandwich_served(quality: int) -> void:
	portrait.try_load_numbered_image(quality)
