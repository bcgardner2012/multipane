extends Node
class_name RCPNode

# Initial calls from clients should include a game name
# We can use game name to select a plug in the ServerImagePane

signal message_received(message)

var registered_game: String

const PORT = 9000
const MAX_CONNECTIONS = 4

var peer = ENetMultiplayerPeer.new()

# when a client connects, mark them as unwatched, new panes can pick them up
var unwatched_streams = []

func next_unwatched_sender_id() -> String:
	return unwatched_streams.pop_front()

func _ready():
	var result = peer.create_server(PORT, MAX_CONNECTIONS)
	if result != OK:
		push_error("Failed to start server: %s" % result)
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	print("Server started on port 9000")

func _on_peer_connected(id: int):
	print("Client connected with ID:", id)
	# Send welcome message to the new client
	rpc_id(id, "receive_message", "Welcome, client %d!" % id)

func _on_peer_disconnected(id: int):
	print("Client disconnected:", id)

# RPC function to add a message stream that one pane will be watching
@rpc("any_peer", "call_local", "reliable")
func claim_pane():
	var sender_id = multiplayer.get_remote_sender_id()
	print("Claiming pane for client ", sender_id)
	unwatched_streams.append(sender_id)

# RPC function to register other running games with image panes
@rpc("any_peer", "call_local", "reliable")
func register_game(game_name: String):
	print("Received game name:", game_name)
	registered_game = game_name

# RPC function to receive messages from clients
@rpc("any_peer", "call_local", "reliable")
func send_message(msg):
	print("Received from client:", msg)
	message_received.emit(msg)

# RPC function to send messages to clients
@rpc("authority")
func receive_message(msg: String):
	print("Message to client:", msg)
