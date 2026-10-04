extends TextureRect
class_name SoccerField

const BALL_X_DELTA = 90.0 #px
const BXD_VECTOR = Vector2(BALL_X_DELTA, 0)
const HALF_BXD_VECTOR = Vector2(BALL_X_DELTA / 2, 0)
const PLAYER_SCORED = 3
const OPPONENT_SCORED = -3

var ball_centered: bool = true

# 0 on half started, -1 to -3 as opponent wins, 1-3 as player wins. -3 and 3 are goals
var ball_position: int  

var _original_position: Vector2

func _ready() -> void:
	_original_position = $Ball.position

# return true if opponent scored
func move_left() -> bool:
	if ball_centered:
		$Ball.position -= HALF_BXD_VECTOR
		ball_centered = false
	else:
		$Ball.position -= BXD_VECTOR
	
	if ball_position == 1:
		ball_position = -1
	else:
		ball_position -= 1
	return ball_position == OPPONENT_SCORED

# return true if player scored
func move_right() -> bool:
	if ball_centered:
		$Ball.position += HALF_BXD_VECTOR
		ball_centered = false
	else:
		$Ball.position += BXD_VECTOR
	
	if ball_position == -1:
		ball_position = 1
	else:
		ball_position += 1
	return ball_position == PLAYER_SCORED

# call when half starts
func reset() -> void:
	ball_centered = true
	$Ball.position = _original_position
	ball_position = 0
