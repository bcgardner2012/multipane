extends Node
class_name HauntedHouseGameStrategy

signal show_text(text: String, color: Color)
signal add_item(item: HauntedHouseGamePlayer.Item)

# Strategy pattern for the various options in Haunted House game

@export var health_gauge: GaugeSlider

var aces_found: int
var _signals: HauntedHouseGamePane

# return true on game over
func handle_card(card: CardData) -> bool:
	show_text.emit("Not implemented", Color.RED)
	return false

# show Nodes specific to this strategy
func show_components() -> void:
	pass

# hide Nodes specific to this strategy
func hide_components() -> void:
	pass

func _change_health(delta: int) -> void:
	health_gauge.change_value(delta)

func _ready() -> void:
	call_deferred("_get_pane_signals")

func _get_pane_signals() -> void:
	# self > Strats > GamePlayer > Pane
	_signals = get_parent().get_parent().get_parent()
