extends TextureRect
class_name OutlawCross

@export var player_cross_texture: Texture2D
@export var npc_cross_texture: Texture2D

enum Owner {
	NONE,
	PLAYER,
	NPC
}

var owning_player: Owner = Owner.NONE

func capture(is_player_turn: bool) -> void:
	if owning_player == Owner.NONE:
		if is_player_turn:
			_give_to_player(Owner.PLAYER)
		else:
			_give_to_player(Owner.NPC)
	elif owning_player == Owner.PLAYER:
		if is_player_turn:
			_give_to_none()
		else:
			_give_to_player(Owner.NPC)
	else:
		if is_player_turn:
			_give_to_player(Owner.PLAYER)
		else:
			_give_to_none()

func clear() -> void:
	_give_to_none()

func _give_to_none() -> void:
	owning_player = Owner.NONE
	visible = false

func _give_to_player(o: Owner) -> void:
	owning_player = o
	visible = true
	if o == Owner.PLAYER:
		texture = player_cross_texture
	else:
		texture = npc_cross_texture
