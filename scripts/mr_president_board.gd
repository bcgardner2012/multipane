extends TextureRect
class_name MrPresidentBoard

const HIGHLIGHT_COLOR = Color(1,1,0)

# these arrays store child indexes
@export var two_point_region: Array[int]
@export var three_point_region: Array[int]
@export var four_point_region: Array[int]
@export var five_point_region: Array[int]
@export var six_point_region: Array[int]
@export var seven_point_region: Array[int]

var regions: Array # of Array of int
var _highlit: MrPresidentChit

func _ready() -> void:
	regions = [
		two_point_region,
		three_point_region,
		four_point_region,
		five_point_region,
		six_point_region,
		seven_point_region
	]

# lowest point value is 2, adjust to zero-index
func get_region_winner(point_value: int) -> CardData.Suit:
	var region = regions[point_value - 2]
	var points: Array[int] = [0,0,0,0]
	var highest = 0
	var winner = CardData.Suit.CLUBS
	for index in region:
		var suit = get_child(index).suit
		points[suit] += 1
		if points[suit] > highest:
			highest = points[suit]
			winner = suit
	
	if _has_tie(points, highest):
		return CardData.Suit.CLUBS
	else:
		return winner
	
func set_area_winner(area: CardData, winner: CardData) -> void:
	var chit = get_child((area.rank - 1) % 13) as MrPresidentChit
	chit.set_suit(winner.suit)

func _has_tie(points: Array[int], highest: int) -> bool:
	var ties = 0
	for pt in points:
		if pt == highest:
			ties += 1
	return ties > 1

# self-modulate a chosen chit to yellow, toggle the last one back to white
func highlight(card: CardData) -> void:
	var index = card.rank - 1
	index %= 13 # Ace is 0 index, but rank 14
	var chit = get_child(index) as MrPresidentChit
	chit.self_modulate = HIGHLIGHT_COLOR
	if _highlit != null:
		_highlit.self_modulate = Color.WHITE
	_highlit = chit
