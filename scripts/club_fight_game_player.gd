extends Node
class_name ClubFightGamePlayer

enum MoveType {
	INVALID,
	MATCH,
	SUM,
	ANY,
	LINE,
	UP_DOWN,
	RUN
}

@export var grid_deck_count_label: Label
@export var club_deck_count_label: Label
@export var grid_node: ClubFightGrid
@export var hand_node: ClubFightHand
@export var move_type_label: Label

var grid_deck: Array[CardData]
var club_deck: Array[CardData]

var grid: Array # Array[Array[CardData]]
var hand: Array[CardData]

var selected_club: CardData
var selected_coordinates: Array[Vector2i] # coordinates in grid
var move_type: MoveType = MoveType.INVALID

var _signals: ClubFightGamePane

func _ready() -> void:
	grid_deck = []
	for card in $GridCards.get_children():
		grid_deck.append(card)
	DeckHelper.shuffle(grid_deck)
	
	club_deck = []
	for card in $Clubs.get_children():
		club_deck.append(card)
	DeckHelper.shuffle(club_deck)

func _on_deck_start_game() -> void:
	# Fill in grid
	grid = []
	var g = DeckHelper.multi_pop(grid_deck, 9)
	for i in range(0, 3):
		grid.append([])
		for j in range(0, 3):
			# j stops at multiples of 3, i restarts counting at last multiple
			grid[i].append(g[i * 3 + j])
	grid_node.show_grid(grid)
	grid_deck_count_label.text = str(grid_deck.size())
	
	# Fill in hand
	hand = DeckHelper.multi_pop(club_deck, 4)
	hand_node.show_cards(hand)
	club_deck_count_label.text = str(club_deck.size())

func _determine_move_type() -> void:
	move_type = MoveType.INVALID
	if selected_club == null or selected_coordinates == []:
		move_type_label.text = "Invalid Selection"
		return
	
	if _is_any_attack():
		move_type = MoveType.ANY
		move_type_label.text = "Any Attack"
	elif _is_line_attack():
		move_type = MoveType.LINE
		move_type_label.text = "Line Attack"
	elif _is_match_attack():
		move_type = MoveType.MATCH
		move_type_label.text = "Match Attack"
	elif _is_run_attack():
		move_type = MoveType.RUN
		move_type_label.text = "Run Attack"
	elif _is_sum_attack():
		move_type = MoveType.SUM
		move_type_label.text = "Sum Attack"
	elif _is_up_down_attack():
		move_type = MoveType.UP_DOWN
		move_type_label.text = "Up/Down Attack"
	else:
		move_type_label.text = "Invalid Selection"

func _grid_has_flush_of(suit: CardData.Suit) -> bool:
	var count = 0
	for row in grid:
		for col in row:
			if col != null and col.suit == suit and col.rank > 0:
				count += 1
	return count >= 3

func _get_cards_used() -> Array[CardData]:
	var cards: Array[CardData] = []
	for v in selected_coordinates:
		cards.append(grid[v.x][v.y])
	cards.append(selected_club)
	return cards

func _remove_and_redraw() -> void:
	_signals.move_made.emit(move_type, _get_cards_used())
	
	for v in selected_coordinates:
		grid[v.x][v.y] = _safe_draw(grid_deck)
	grid_deck_count_label.text = str(grid_deck.size())
	grid_node.show_grid(grid)
	
	hand.remove_at(hand.find(selected_club))
	hand.append(_safe_draw(club_deck))
	hand_node.show_cards(hand)
	club_deck_count_label.text = str(club_deck.size())
	
	hand_node.deselect()
	grid_node.deselect()
	
	selected_club = null
	selected_coordinates = []
	move_type = MoveType.INVALID
	move_type_label.text = "Invalid Selection"

func _safe_draw(deck: Array[CardData]): # returns CardData or null
	if deck.size() > 0:
		return deck.pop_front()
	return null

# Validations

# selected grid cards match rank of selected hand card
func _is_match_attack() -> bool:
	for v in selected_coordinates:
		if grid[v.x][v.y].rank != selected_club.rank:
			return false
	return true

func _is_sum_attack() -> bool:
	var target = selected_club.rank
	var sum = 0
	for v in selected_coordinates:
		sum += grid[v.x][v.y].rank
	return target == sum

# selected 1 card from hand and 1 from grid
func _is_any_attack() -> bool:
	return selected_club != null and selected_coordinates.size() == 1

# Blockable validations, return false if 3 of a certain suit exist in grid

# line attack requires 4 different checks
func _is_line_attack() -> bool:
	if _grid_has_flush_of(CardData.Suit.DIAMONDS):
		return false
	
	# are 3 grid cards selected?
	if selected_coordinates.size() != 3:
		return false
	
	# is all same row?
	var same_row = true
	var y = selected_coordinates[0].y
	for v in selected_coordinates:
		if y != v.y:
			# different row
			same_row = false
			break
	
	# is all same column?
	var same_col = true
	var x = selected_coordinates[0].x
	for v in selected_coordinates:
		if x != v.x:
			# different col
			same_col = false
			break
	
	if not (same_row or same_col):
		return false
	
	# does that contain the club rank?
	for v in selected_coordinates:
		if grid[v.x][v.y].rank == selected_club.rank:
			return true
	return false

# checks vary by club card
func _is_up_down_attack() -> bool:
	if _grid_has_flush_of(CardData.Suit.SPADES):
		return false
	
	# 2-6, cards are less than?
	if selected_club.rank >= 2 and selected_club.rank < 7:
		for v in selected_coordinates:
			if grid[v.x][v.y].rank >= selected_club.rank or grid[v.x][v.y].rank < 0:
				return false
		return true
	
	# 8-Q, cards are greater than?
	elif selected_club.rank >= 8 and selected_club.rank < 13:
		for v in selected_coordinates:
			if grid[v.x][v.y].rank <= selected_club.rank:
				return false
		return true
	
	# 7, all other cards are strictly greater or all less than
	elif selected_club.rank == 7:
		var all_greater = true
		for v in selected_coordinates:
			if grid[v.x][v.y].rank <= selected_club.rank:
				all_greater = false
		
		if all_greater:
			return true
		
		var all_lesser = true
		for v in selected_coordinates:
			if grid[v.x][v.y].rank >= selected_club.rank:
				all_lesser = false
		
		return all_lesser 
	return false # selected Ace or King, or not valid

# do grid cards form a straight around the club card?
func _is_run_attack() -> bool:
	if _grid_has_flush_of(CardData.Suit.HEARTS):
		return false
	
	# get all ranks, sort them
	var ranks: Array[int] = []
	for v in selected_coordinates:
		ranks.append(grid[v.x][v.y].rank)
	ranks.append(selected_club.rank)
	ranks.sort()
	# check for gaps and dupes
	for i in range(0, ranks.size()-1):
		if ranks[i+1] - ranks[i] != 1:
			return false
	return true

# Event Handlers

func _on_hand_select_card(card: CardData) -> void:
	selected_club = card
	_determine_move_type()


func _on_hand_deselect_card() -> void:
	selected_club = null
	_determine_move_type()


func _on_grid_select_card(_card: CardData, coordinates: Vector2i) -> void:
	if selected_coordinates.find(coordinates) == -1:
		selected_coordinates.append(coordinates)
		_determine_move_type()
	else:
		print("Error: couldn't find selected grid card")


func _on_grid_deselect_card(_card: CardData, coordinates: Vector2i) -> void:
	var sc = selected_coordinates.find(coordinates)
	if sc != -1:
		selected_coordinates.remove_at(sc)
		_determine_move_type()
	else:
		print("Error: grid card to deselect not found")

func _on_confirm_button_pressed() -> void:
	if move_type != MoveType.INVALID:
		_remove_and_redraw()
