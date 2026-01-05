extends Node
class_name PortraitHelper

# Seeburg selector is the mechanism for selecting a song from an old juke box
# from is the first numbered image to look for, cycling up until to (exclusive)
static func seeburg_select(portrait: Portrait, from: int, to: int, step: int = 1) -> void:
	for i in range(from, to, step):
		if portrait.try_load_numbered_image(i):
			break

static func seeburg_select_subdir(portrait: Portrait, from: int, to: int, subdir: String, step: int = 1) -> void:
	for i in range(from, to, step):
		if portrait.try_load_numbered_image_from_subdir(i, subdir):
			break
