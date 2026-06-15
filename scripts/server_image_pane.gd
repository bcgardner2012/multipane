extends Control
class_name ServerImagePane

# I'm thinking since separate games tend to be more complex and have more
# involved "scenes" we'd want to show, this should ultimately be a pane
# that shows 2-5 images panes (1 large, 2 verticals, 4(?) square) in sequence as
# events are received.

func _ready() -> void:
	RcpNode.message_received.connect(_on_rcp_node_message_received)

func _on_rcp_node_message_received(msg) -> void:
	print("on trigger")
	if RcpNode.registered_game == "ButtonMen":
		var plug = $Plugs/ButtonMenPlug
		plug.on_message_received(msg)
