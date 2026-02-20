extends GamePlug
class_name CardCaptureGamePlug

const POWERLEVEL_CHANNEL = 0 # show image based only on powerlevel
const CAPTURE_CHANNEL = 1 # show image based on card captured, mainly

const POWERLEVEL_DIR = "powerlevel"
const GENERIC_DIR = "generic"

func on_captured(enemy: CardData, powerlevel: int) -> void:
	var channel = _get_suit_channel()
	if channel == POWERLEVEL_CHANNEL:
		PortraitHelper.seeburg_select_subdir(portrait, powerlevel, 0, POWERLEVEL_DIR, -1)
	elif channel == CAPTURE_CHANNEL:
		if enemy.rank < 11:
			# iterate dirs down from powerlevel until found matching dir
			for i in range(powerlevel, 0, -1):
				if portrait.try_load_random_image_from_subdir(GENERIC_DIR.path_join(str(i))):
					return
		else:
			PortraitHelper.seeburg_select_subdir(portrait, powerlevel, 0, _card_to_notation(enemy), -1)
