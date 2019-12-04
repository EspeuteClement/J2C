extends Node2D

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var is_server = false;

const SERVER_PORT = 987;
const MAX_PLAYERS = 2;

const CARD_PER_ROW = 6;
const CARD_PER_COLUMN = 6;

var count_card_offense = 0;
var count_card_defense = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var args = Array(OS.get_cmdline_args());
	
	if (args.has("-s")):
		print("Starting game as a server ...");
		is_server = true;
		
	
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

const CARDS_PER_LINE_DISPLAY = 10;

func strip_spaces(s :String) -> String:
	return s.strip_edges();
#	s = s.replace(" ", "");
#	s = s.replace("\t", "");

func _genetrate_card(props : Array, sides_flags : int, id : int, gen_data : Dictionary) -> Node2D:
	var new_card : Card = preload("res://Scenes/Card.tscn").instance();
	var index;
	new_card.card_name = props[CardProp.NAME].strip_edges();
	
	match props[CardProp.TYPE].strip_edges().to_lower():
		"offense":
			new_card.card_type = Card.CardType.OFFENSE;
		"defense":
			new_card.card_type = Card.CardType.DEFENSE;
		var wrong_type:
			#printerr("Line %d type is invalid : %s" % [nb_line, wrong_type]);
			new_card.card_type = Card.CardType.OFFENSE;
	
	#Sides :

	new_card.notch_flags = sides_flags;
	for i in range(4):
		var side = sides_flags & 1 << i;
		if (side > 0):
			new_card.values[i] = 1;
		else:
			new_card.values[i] = -1;
	
	index = Card.condition_animation_name.values().find(props[CardProp.CONDITION_TYPE].strip_edges().to_lower());
	
	if (index == -1):
		printerr("Couldn't find condition for card %d" % id);
		new_card.queue_free();
		return null;
	else:
		new_card.card_condition = index;
		
	index = Card.attribute_animation_name.values().find(props[CardProp.ATTRIBUTE].strip_edges().to_lower());
	if (index == -1):
		printerr("Couldn't find attribute for card %d" % id);
		new_card.queue_free();
		return null;
	else:
		new_card.card_attribute = index;			

	new_card.activation_text = props[CardProp.CONDITION_TEXT].strip_edges();
	new_card.effect_text = props[CardProp.EFFECT_TEXT].strip_edges();
	
	new_card.card_value = int(props[CardProp.VALUE].strip_edges());

	
	new_card.card_id = id;
	
	if (new_card):
		new_card.position.x = (gen_data.counter % CARDS_PER_LINE_DISPLAY) * 360;
		new_card.position.y = int(gen_data.counter / CARDS_PER_LINE_DISPLAY) * 500;
		
		get_tree().get_root().get_node("Board/CardDB").add_child(new_card);
		gen_data.counter +=1;
	
	if(!CardDatabase.Data.has(id)):
		CardDatabase.Data[id] = Dictionary();
	
	CardDatabase.Data[id][sides_flags] = new_card;
	
	var value_to_use = 0;
	match new_card.card_type:
		Card.CardType.OFFENSE:
			value_to_use = count_card_offense;
			count_card_offense += 1;
		Card.CardType.DEFENSE:
			value_to_use = count_card_defense;
			count_card_defense += 1;
			
	new_card.card_x = (value_to_use % (CARD_PER_ROW * CARD_PER_COLUMN)) % CARD_PER_ROW;
	new_card.card_y = (value_to_use % (CARD_PER_ROW * CARD_PER_COLUMN)) / CARD_PER_ROW;
	new_card.card_deck_id = 3 + int(value_to_use / (CARD_PER_COLUMN * CARD_PER_ROW));
	new_card.card_export_id = new_card.card_deck_id * 100 + (value_to_use % (CARD_PER_COLUMN * CARD_PER_ROW));
				
	return new_card;

func _on_Imoprt_pressed() -> void:
	CardDatabase.Data.clear();
	var path = "import/import.cdb";
	var f:File = File.new();
	var err:int = f.open(path, File.READ);
	
	var cardDB : Node2D = get_tree().get_root().get_node("Board/CardDB"); 
	
	count_card_offense = 0;
	count_card_defense = 0;
	
	if (!err):
		# Remove all children of card db
		for child in cardDB.get_children():
			child.queue_free();

		var counter = 0;
		var nb_line = 0;
		
		var gen_data = {
			counter = 0,
		};
		
		var id = 0;
		
		
		var rng = 4
		# Skip first line
		f.get_csv_line();
		while(!f.eof_reached()):
			var index;
			var line = f.get_csv_line();
			nb_line += 1;
			
			if (line.size() != CardProp.COUNT):
				printerr("Line %d in %s is illformed, skipping" % [nb_line, path]);
				continue;
			var nb_notches = int(line[CardProp.NOTCH_COUNT].strip_edges());
			
			match nb_notches:
				0:
					_genetrate_card(line, 0, id, gen_data);
				1: 
					_genetrate_card(line, 0x1, id, gen_data);
					_genetrate_card(line, 0x2, id, gen_data);
					_genetrate_card(line, 0x4, id, gen_data);
					_genetrate_card(line, 0x8, id, gen_data);
				2: 
					_genetrate_card(line, 0x1 | 0x02, id, gen_data);
					_genetrate_card(line, 0x1 | 0x04, id, gen_data);
					_genetrate_card(line, 0x1 | 0x08, id, gen_data);
					_genetrate_card(line, 0x2 | 0x04, id, gen_data);
					_genetrate_card(line, 0x2 | 0x08, id, gen_data);
					_genetrate_card(line, 0x4 | 0x08, id, gen_data);
				3:
					_genetrate_card(line, 0xF ^ 0x1, id, gen_data);
					_genetrate_card(line, 0xF ^ 0x2, id, gen_data);
					_genetrate_card(line, 0xF ^ 0x4, id, gen_data);
					_genetrate_card(line, 0xF ^ 0x8, id, gen_data);
				4:
					_genetrate_card(line, 0xF, id, gen_data);
				_:
					printerr("Too Much sides");

			id += 1;
	else:
		printerr("Couldn't open file %s. Error %d" % [path, err]);

	f.close();	

func _on_Download_pressed() -> void:
	var error = OS.execute("Wget/dl.bat", [], true);
	
	#var error = $HTTPRequest.request(url, PoolStringArray( ), false, HTTPClient.METHOD_GET);
	print(error);
