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
	TYPE,
	CONDITION_TEXT,
	EFFECT_TEXT,
	CONDITION_TYPE,
	ATTRIBUTE,
	VALUE,
	NOTCH_COUNT,
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
		var nb_line = 0;
		var CARDS_PER_LINE = 10;
		
		var rng = 4
		# Skip first line
		f.get_csv_line();
		while(!f.eof_reached()):
			var index;
			var line = f.get_csv_line();
			nb_line += 1;
			var card_is_valid = true;
			
			if (line.size() != CardProp.COUNT):
				printerr("Line %d in %s is illformed, skipping" % [nb_line, path]);
				continue;
			
			var new_card : Card = preload("res://Scenes/Card.tscn").instance();
			new_card.card_name = line[CardProp.NAME].strip_edges();
			
			match line[CardProp.TYPE].strip_edges().to_lower():
				"offense":
					new_card.card_type = Card.CardType.OFFENSE;
				"defense":
					new_card.card_type = Card.CardType.DEFENSE;
				var wrong_type:
					printerr("Line %d type is invalid : %s" % [nb_line, wrong_type]);
					new_card.card_type = Card.CardType.OFFENSE;
			
			#Sides :
			var sides = Card.Dir.values();
			sides.pop_back(); #remove COUNT
			sides.shuffle();
			
			var nb_notches = int(line[CardProp.NOTCH_COUNT].strip_edges());
			
			for i in range(4):
				var side = sides.pop_front();
				if (i < nb_notches):
					new_card.values[side] = 1;
				else:
					new_card.values[side] = -1;
			
			index = Card.condition_animation_name.values().find(line[CardProp.CONDITION_TYPE].strip_edges().to_lower());
			
			if (index == -1):
				printerr("Couldn't find condition for card %d" % nb_line);
				card_is_valid = false;
			else:
				new_card.card_condition = index;
				
			index = Card.attribute_animation_name.values().find(line[CardProp.ATTRIBUTE].strip_edges().to_lower());
			if (index == -1):
				printerr("Couldn't find attribute for card %d" % nb_line);
				card_is_valid = false;
			else:
				new_card.card_attribute = index;			

			new_card.activation_text = line[CardProp.CONDITION_TEXT].strip_edges();
			new_card.effect_text = line[CardProp.EFFECT_TEXT].strip_edges();
			
			new_card.card_value = int(line[CardProp.VALUE].strip_edges());
			
			new_card.position.x = (counter % CARDS_PER_LINE) * 360;
			new_card.position.y = int(counter / CARDS_PER_LINE) * 500;
			
			if (card_is_valid):
				cardDB.add_child(new_card);
				counter +=1;
			else:
				new_card.queue_free();


	else:
		printerr("Couldn't open file %s. Error %d" % [path, err]);

	f.close();	

func _on_Download_pressed() -> void:
	var error = OS.execute("Wget/dl.bat", [], true);
	
	#var error = $HTTPRequest.request(url, PoolStringArray( ), false, HTTPClient.METHOD_GET);
	print(error);
