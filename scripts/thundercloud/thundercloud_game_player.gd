extends Node
class_name ThundercloudGamePlayer

@export var dice_node: ThundercloudGameDice
@export var graphics: Array[ThundercloudGameGraphic]

var whose_turn: int
var hidden_count: int

var _signals: ThundercloudGamePane

func _ready() -> void:
	_signals = get_parent()

# advance the game
func _on_d6_left_clicked(_node: D6) -> void:
	if graphics.size() == 1:
		# game over, stop responding
		return
	
	var rolls = dice_node.roll()
	var one_count = IntArrayHelper.count_of(rolls, 1)
	var struck = false
	if one_count > 0:
		hidden_count += one_count
		if hidden_count >= dice_node.get_child_count():
			dice_node.show_all()
			hidden_count = 0
		else:
			dice_node.hide_dice(one_count)
	else:
		struck = graphics[whose_turn].show_next_segment()
	
	if struck:
		_signals.struck.emit(graphics[whose_turn].color)
		graphics.remove_at(whose_turn)
		# only update turn if the last player in list was struck
		if whose_turn == graphics.size() - 1:
			whose_turn += 1
			whose_turn %= graphics.size()
		
		if graphics.size() == 1:
			_signals.game_over.emit(graphics[0].color)
	else:
		_signals.not_struck.emit(graphics[whose_turn].color)
		# only update turn counter if player not struck, otherwise turns are skipped
		whose_turn += 1
		whose_turn %= graphics.size()
	
	if whose_turn >= graphics.size():
		whose_turn = 0
	dice_node.set_color(graphics[whose_turn].color)
