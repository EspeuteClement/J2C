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

enum CardProp {
	NAME,
	RIGHT,
	TOP,
	LEFT,
	DOWN,
	ATTRIBUTE,
	VALUE,
	VALUE_TYPE,
	ACTIVATION_TYPE,
	ACTIVATION_TEXT,
	EFFECT_TEXT,
	COUNT
};

func strip_spaces(s :String) -> String:
	return s.strip_edges();
#	s = s.replace(" ", "");
#	s = s.replace("\t", "");

func _on_Imoprt_pressed() -> void:
	var path = "import/import.cdb";
	var f:File = File.new();
	var err:int = f.open(path, File.READ);
	
	var cardDB : Node2D = get_tree().get_root().get_node("Board/CardDB"); 
	
	if (!err):
		# Remove all children of card db
		for child in cardDB.get_children():
			child.queue_free();

		var counter = 0;
		var CARDS_PER_LINE = 10;
		
		while(!f.eof_reached()):
			var line = f.get_csv_line();
			if (line.size() != CardProp.COUNT):
				printerr("Line %d in %s is illformed, skipping" % [counter, path]);
				continue;
			
			var new_card : Card = preload("res://Scenes/Card.tscn").instance();
			new_card.card_name = line[CardProp.NAME].strip_edges();
			
			new_card.values[Card.Dir.Right] = int(line[CardProp.RIGHT].strip_edges());
			new_card.values[Card.Dir.Top] = int(line[CardProp.TOP].strip_edges());
			new_card.values[Card.Dir.Left] = int(line[CardProp.LEFT].strip_edges());
			new_card.values[Card.Dir.Down] = int(line[CardProp.DOWN].strip_edges());
			
			new_card.activation_text = line[CardProp.ACTIVATION_TEXT].strip_edges();
			new_card.effect_text = line[CardProp.EFFECT_TEXT].strip_edges();
			
			new_card.position.x = (counter % CARDS_PER_LINE) * 360;
			new_card.position.y = int(counter / CARDS_PER_LINE) * 500;
			
			cardDB.add_child(new_card);
			
			counter +=1;

	else:
		printerr("Couldn't open file %s. Error %d" % [path, err]);

	f.close();	