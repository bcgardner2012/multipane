extends GamePlug
class_name ZombieDiceGamePlug

# channel 0-2 is for survivor slots
# channel 3 is for player

const SLOT1 = "slot1"
const SLOT2 = "slot2"
const SLOT3 = "slot3"

# survivors 10-k

func on_cards_drawn(survivors: Array[CardData], actions: Array[CardData]) -> void:
	var channel = _get_suit_channel()
	if channel >= 0 or channel <= 2:
		var survivor = _card_to_notation(survivors[channel])
		var action = _suit_to_action(actions[channel])
		# check for 10-k subdir, else use slot<channel+1>
		if not portrait.try_load_random_image_from_subdir(survivor.path_join(action)):
			var slot = "slot" + str(channel+1)
			portrait.try_load_random_image_from_subdir(slot.path_join(action))
		# TODO: track and update per char health? Maybe without image update

# try with one char (won_kd), fallback to just "won", fuck the sorting logic for all 3
func on_round_won(survivors: Array[CardData]) -> void:
	var channel = _get_suit_channel()
	if channel == 3:
		var loaded = false
		for i in range(0,2):
			var suffix = _card_to_notation(survivors[i])
			loaded = portrait.try_load_random_image_from_subdir("won_".path_join(suffix))
			if loaded:
				break
		
		if not loaded:
			portrait.try_load_random_image_from_subdir("won")

# try with one char (won_kd), fallback to just "won", fuck the sorting logic for all 3
func on_round_lost(survivors: Array[CardData]) -> void:
	var channel = _get_suit_channel()
	if channel == 3:
		var loaded = false
		for i in range(0,2):
			var suffix = _card_to_notation(survivors[i])
			loaded = portrait.try_load_random_image_from_subdir("lost_".path_join(suffix))
			if loaded:
				break
		
		if not loaded:
			portrait.try_load_random_image_from_subdir("lost")

func _suit_to_action(card: CardData) -> String:
	if card.suit == CardData.Suit.HEARTS:
		return "brain"
	elif card.suit == CardData.Suit.CLUBS:
		return "bullet"
	else:
		return "flee"
