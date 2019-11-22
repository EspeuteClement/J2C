extends Node2D

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var is_server = false;

const SERVER_PORT = 987;
const SERVER_ADRESS = "clementespeute.com";
const MAX_PLAYERS = 2;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var args = Array(OS.get_cmdline_args());
	
	if (args.has("-s")):
		print("Starting game as a server ...");
		is_server = true;
		
	if (is_server):
		var peer = NetworkedMultiplayerENet.new();
		peer.create_server(SERVER_PORT, MAX_PLAYERS);
		get_tree().set_network_peer(peer);
	else:
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client(SERVER_ADRESS, SERVER_PORT);
		get_tree().set_network_peer(peer)
	
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
