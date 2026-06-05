extends Control
class_name ServerImagePane

func _ready() -> void:
	RcpNode.message_received.connect(_on_rcp_node_message_received)

func _on_rcp_node_message_received(msg) -> void:
	print("on trigger")
	if RcpNode.registered_game == "ButtonMen":
		var plug = $Plugs/ButtonMenPlug
		plug.on_message_received(msg)
