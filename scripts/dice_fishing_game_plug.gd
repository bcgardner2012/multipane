extends GamePlug
class_name DiceFishingGamePlug

#const D11 = "mackerel1"
#const D12 = "mackerel2"
#const D21 = "grouper1"
#const D22 = "grouper2"
#const D31 = "snapper1"
#const D32 = "snapper2"
#const D41 = "tuna1"
#const D42 = "tuna2"
#const D51 = "mahi1"
#const D52 = "mahi2"
#const D61 = "marlin1"
#const D62 = "marlin2"

func on_catch(_name: String) -> void:
	portrait.try_load_random_image_from_subdir(_name)

func on_game_over() -> void:
	portrait.try_load_random_image_from_subdir("game_over")

func on_game_won() -> void:
	portrait.try_load_random_image_from_subdir("game_won")

func on_nada() -> void:
	portrait.try_load_random_image_from_subdir("nada")
