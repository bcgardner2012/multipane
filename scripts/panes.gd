extends Control
class_name Panes

enum Orientation {
	PORTRAIT,
	LANDSCAPE
}

@onready var pane_selector_scene = preload("res://scenes/pane_selector_pane.tscn")
@onready var pane_scene = preload("res://scenes/pane.tscn")
@onready var scoundrel_game_scene = preload("res://scenes/scoundrel_game.tscn")
@onready var area_52_game_scene = preload("res://scenes/area_52_game.tscn")

@onready var orientation = Orientation.PORTRAIT

var childCount: int
var should_add_image_pane: bool
var should_add_scoundrel_game_pane: bool
var should_add_area_52_game_pane: bool

func queue_add_image_pane() -> void:
	should_add_image_pane = true

func queue_add_scoundrel_game_pane() -> void:
	should_add_scoundrel_game_pane = true
	
func queue_add_area_52_game_pane() -> void:
	should_add_area_52_game_pane = true

func _add_pane(scene: Resource) -> void:
	# we are designing with up to 4 panes in mind
	if get_child_count() < 4:
		add_child(scene.instantiate())
		_reorganize()

func _on_add_pane_button_pressed() -> void:
	_add_pane(pane_selector_scene)

func _process(_delta: float) -> void:
	if should_add_image_pane:
		_add_pane(pane_scene)
		should_add_image_pane = false
	if should_add_scoundrel_game_pane:
		_add_pane(scoundrel_game_scene)
		should_add_scoundrel_game_pane = false
	elif should_add_area_52_game_pane:
		_add_pane(area_52_game_scene)
		should_add_area_52_game_pane = false
	
	if childCount != get_child_count():
		if childCount > get_child_count():
			# a child was deleted, resize everything
			_reorganize()
		childCount = get_child_count()

func _reorganize() -> void:
	# 1 pane? Full width, full height
	# 2 panes? Ambiguous, use orientation button to choose.
	# 3 panes? Half height, half width on top, full width on bottom
	# 4 panes? Half all around
	var count = get_child_count()
	if count == 1:
		var pane = get_child(0) as Control
		pane.set_anchors_preset(Control.PRESET_FULL_RECT)
	elif count == 2 and orientation == Orientation.PORTRAIT:
		_reorganize_portrait_mode()
	elif count == 2 and orientation == Orientation.LANDSCAPE:
		_reorganize_landscape_mode()
	elif count == 3:
		var leftPane = get_child(0) as Control
		var rightPane = get_child(1) as Control
		var bottomPane = get_child(2) as Control
		leftPane.anchor_left = 0.0
		leftPane.anchor_right = 0.5
		leftPane.anchor_top = 0.0
		leftPane.anchor_bottom = 0.5
		rightPane.anchor_left = 0.5
		rightPane.anchor_right = 1.0
		rightPane.anchor_top = 0.0
		rightPane.anchor_bottom = 0.5
		bottomPane.anchor_left = 0.0
		bottomPane.anchor_right = 1.0
		bottomPane.anchor_top = 0.5
		bottomPane.anchor_bottom = 1.0
	elif count == 4:
		var upLeft = get_child(0) as Control
		var upRight = get_child(1) as Control
		var downLeft = get_child(2) as Control
		var downRight = get_child(3) as Control
		upLeft.anchor_left = 0.0
		upLeft.anchor_right = 0.5
		upLeft.anchor_top = 0.0
		upLeft.anchor_bottom = 0.5
		upRight.anchor_left = 0.5
		upRight.anchor_right = 1.0
		upRight.anchor_top = 0.0
		upRight.anchor_bottom = 0.5
		downLeft.anchor_left = 0.0
		downLeft.anchor_right = 0.5
		downLeft.anchor_top = 0.5
		downLeft.anchor_bottom = 1.0
		downRight.anchor_left = 0.5
		downRight.anchor_right = 1.0
		downRight.anchor_top = 0.5
		downRight.anchor_bottom = 1.0
	
	if count > 0:
		for child in get_children():
			_reset_offsets(child)

func _reorganize_portrait_mode() -> void:
	var leftPane = get_child(0) as Control
	var rightPane = get_child(1) as Control
	leftPane.anchor_left = 0.0
	leftPane.anchor_right = 0.5
	leftPane.anchor_top = 0.0
	leftPane.anchor_bottom = 1.0
	rightPane.anchor_left = 0.5
	rightPane.anchor_right = 1.0
	rightPane.anchor_top = 0.0
	rightPane.anchor_bottom = 1.0

func _reorganize_landscape_mode() -> void:
	var topPane = get_child(0) as Control
	var bottomPane = get_child(1) as Control
	topPane.anchor_left = 0.0
	topPane.anchor_right = 1.0
	topPane.anchor_top = 0.0
	topPane.anchor_bottom = 0.5
	bottomPane.anchor_left = 0.0
	bottomPane.anchor_right = 1.0
	bottomPane.anchor_top = 0.5
	bottomPane.anchor_bottom = 1.0

func _reset_offsets(node: Control) -> void:
	node.offset_bottom = 0
	node.offset_left = 0
	node.offset_right = 0
	node.offset_top = 0


func _on_change_orientation_button_pressed() -> void:
	if orientation == Orientation.PORTRAIT:
		orientation = Orientation.LANDSCAPE
	else:
		orientation = Orientation.PORTRAIT
	_reorganize()
