extends Node
class_name HauntedHouseGamePlayer

signal show_text(text: String, color: Color)

@export var health_gauge: GaugeSlider
@export var draw_node: Card
@export var deck_count_label: Label
@export var settings: Control
@export var items_node: HauntedHouseItems

var deck: Array[CardData]
var _strategy: HauntedHouseGameStrategy

var is_game_over: bool

enum Item {
	CANDLE,
	SPRAY,
	HOLY_WATER,
	FLASHLIGHT,
	BANDAGE,
	DOLL
}

func _ready() -> void:
	deck = []
	for child in $CardDatas.get_children():
		var card = child as CardData
		deck.append(card)
	DeckHelper.shuffle(deck)
	
	# core logic per draw, determined by settings chosen
	_strategy = $Strategies/DefaultStrategy


func _on_deck_start_game() -> void:
	settings.visible = false
	_on_deck_deck_clicked()


func _on_deck_deck_clicked() -> void:
	if is_game_over:
		return
	
	var card = _safe_pop()
	if card == null:
		return # game over
	draw_node.set_card_data(card)
	is_game_over = _strategy.handle_card(card)
	if is_game_over:
		if _strategy.aces_found == 4:
			show_text.emit("You won!", Color.GREEN)
		else:
			show_text.emit("Game Over", Color.RED)

func _safe_pop():
	if deck.size() > 0:
		deck_count_label.text = str(deck.size()-1)
		return deck.pop_front()
	return null

const DEFAULT_MODE = 0
const DELUXE_MODE = 1
const ANC_MODE = 2
func _on_game_mode_selected(index: int) -> void:
	if _strategy != null:
		_strategy.hide_components()
	
	match index:
		DEFAULT_MODE:
			_strategy = $Strategies/DefaultStrategy
		DELUXE_MODE:
			_strategy = $Strategies/DeluxeStrategy
		ANC_MODE:
			_strategy = $Strategies/AncStrategy
	
	_strategy.show_components()


func _on_add_item(item: HauntedHouseGamePlayer.Item) -> void:
	items_node.show_item(item)
