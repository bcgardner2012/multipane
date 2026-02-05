extends GamePlug
class_name OutlawGamePlug

func on_outlaw_claimed(sum: int, new_owner: OutlawCross.Owner, prev_owner: OutlawCross.Owner) -> void:
	var suffix = ""
	if _escaped(new_owner, prev_owner):
		suffix = str(sum).path_join("escape")
		portrait.try_load_random_image_from_subdir(suffix)
	elif _captured(new_owner, prev_owner):
		suffix = str(sum).path_join("capture")
		portrait.try_load_random_image_from_subdir(suffix)
	elif _stolen(new_owner, prev_owner):
		suffix = str(sum).path_join("stolen")
		if not portrait.try_load_random_image_from_subdir(suffix):
			suffix = str(sum).path_join("capture")
			portrait.try_load_random_image_from_subdir(suffix)

# largest possible delta is 27,000, min is 4000. Label images 27 - 4
func on_bounty_collected(delta: int, is_player_turn: bool) -> void:
	if (is_player_turn and _get_suit_channel() == 0) or (not is_player_turn and _get_suit_channel() == 1):
		PortraitHelper.seeburg_select_subdir(portrait, delta / 1000, 3, "bounty", -1)

func on_player_won() -> void:
	portrait.try_load_random_image_from_subdir("won")

func on_player_lost() -> void:
	portrait.try_load_random_image_from_subdir("lost")

func _escaped(new_owner: OutlawCross.Owner, prev_owner: OutlawCross.Owner) -> bool:
	var e = (new_owner == OutlawCross.Owner.NONE and prev_owner != OutlawCross.Owner.NONE)
	return e and _channel_matches(prev_owner)

func _captured(new_owner: OutlawCross.Owner, prev_owner: OutlawCross.Owner) -> bool:
	var c = (new_owner == OutlawCross.Owner.PLAYER or new_owner == OutlawCross.Owner.NPC) and prev_owner == OutlawCross.Owner.NONE
	return c and _channel_matches(new_owner)

func _stolen(new_owner: OutlawCross.Owner, prev_owner: OutlawCross.Owner) -> bool:
	var s = (new_owner == OutlawCross.Owner.PLAYER or new_owner == OutlawCross.Owner.NPC) and prev_owner != OutlawCross.Owner.NONE
	return s and _channel_matches(new_owner)

func _channel_matches(o: OutlawCross.Owner) -> bool:
	return ((_get_suit_channel() == 0 and o == OutlawCross.Owner.PLAYER) or (_get_suit_channel() == 1 and o == OutlawCross.Owner.NPC))
