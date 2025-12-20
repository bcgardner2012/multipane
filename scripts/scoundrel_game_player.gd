extends Node
class_name ScoundrelGamePlayer

@export var room: Control
@export var deck_label: Label
@export var health_slider: GaugeSlider
@export var weapon_node: TextureRect
@export var run_button: TextureButton

const DEFAULT_DURABILITY = 15

var equipped_weapon: CardData
var durability: int

var cards_resolved: int
var can_run: bool
var can_heal: bool

var deck: Array[Node] # all nodes should use CardData script
var game_in_progress: bool

# Called when the node enters the scene tree for the first time, after children
# have ready() 'd
func _ready() -> void:
	randomize()
	deck = get_child(0).get_children()
	_shuffle_deck()

# Fisher-Yates Shuffle Algorithm
func _shuffle_deck() -> void:
	var i = deck.size()
	while i > 0:
		var r = randi() % i
		var tmp = deck[r]
		deck[r] = deck[i-1]
		deck[i-1] = tmp
		i -= 1


func _on_deck_start_game() -> void:
	if not game_in_progress:
		game_in_progress = true
		var cards = room.get_children()
		for card in cards:
			card.set_card_data(deck.pop_front())
		deck_label.text = str(deck.size())
		can_heal = true
		_set_can_run(true)
		_signals().game_started.emit()


func _on_card_use_card(data: CardData, button_index: int) -> void:
	_set_can_run(false)
	if data.suit == CardData.Suit.HEARTS:
		# Heal
		if can_heal:
			health_slider.change_value(data.rank)
			_signals().health_changed.emit(data.rank, false, data)
			can_heal = false
			_signals().potion_used.emit(data)
		else:
			_signals().potion_discarded.emit(data)
	elif data.suit == CardData.Suit.DIAMONDS:
		# Equip
		equipped_weapon = data
		durability = DEFAULT_DURABILITY
		weapon_node.texture = data.texture
		weapon_node.get_child(0).text = str(durability)
		_signals().weapon_equipped.emit(data)
	else:
		# Fight monster (left-click means with weapon, right means barehanded)
		if button_index == MOUSE_BUTTON_LEFT and durability > data.rank:
			durability = data.rank
			weapon_node.get_child(0).text = str(durability)
			var delta = -clampi(data.rank - equipped_weapon.rank, 0, 20)
			health_slider.change_value(delta)
			if delta < 0:
				_signals().health_changed.emit(delta, false, data)
		else:
			health_slider.change_value(-data.rank)
			_signals().health_changed.emit(-data.rank, true, data)
		
		_signals().monster_killed.emit(data)
	
	cards_resolved += 1
	if cards_resolved >= 3 and deck.size() > 0:
		can_heal = true
		_set_can_run(true)
		_signals().room_cleared.emit()
		_refill_room(data)
	
	_check_victory()
	_check_failure(data)

# data: the card that triggered the refill, it also needs to be updated
func _refill_room(data: CardData) -> void:
	cards_resolved = 0
	for card_node in room.get_children():
		if card_node.data == null or (data != null and (card_node.data.equals(data))):
			if deck.size() > 0:
				card_node.set_card_data(deck.pop_front())
	deck_label.text = str(deck.size())

func _force_refill_room() -> void:
	cards_resolved = 0
	for card_node in room.get_children():
		card_node.set_card_data(deck.pop_front())

func _on_run_button_pressed() -> void:
	cards_resolved = 0
	for card_node in room.get_children():
		if card_node.data != null:
			deck.push_back(card_node.data)
	
	_set_can_run(false)
	_force_refill_room()
	_signals().fled.emit()

func _set_can_run(c: bool) -> void:
	can_run = c
	run_button.visible = c

func _check_victory() -> void:
	if deck.size() == 0:
		for card in room.get_children():
			if (card as Card).data == null:
				_signals().victory.emit()

func _check_failure(monster: CardData) -> void:
	if health_slider.currentValue <= 0:
		_signals().failure.emit(monster)

func _signals() -> ScoundrelGamePane:
	return get_parent() as ScoundrelGamePane
