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
	SHEET_ID,
	NAME,
	TYPE,
	CONDITION_TEXT,
	EFFECT_TEXT,
	CONDITION_TYPE,
	ATTRIBUTE,
	VALUE,
	NOTCH_COUNT,
	TAGS,
	COUNT
};

enum CardPropNew {
	CARD_ID,
	NAME,
	ATTRIBUTE,
	VALUE,
	NOTCHES,
	CONDITION_1,
	ACTIVATION_1,
	EFFECT_1,
	CONDITION_2,
	ACTIVATION_2,
	EFFECT_2,
	COUNT
};

const CARDS_PER_LINE_DISPLAY = 10;

func strip_spaces(s :String) -> String:
	return s.strip_edges();
#	s = s.replace(" ", "");
#	s = s.replace("\t", "");


func _generate_card_new(props : Array, notches : int, gen_data : Dictionary) -> void:
	var _id = int(props[CardPropNew.CARD_ID].strip_edges());
	var new_card : CardNew = preload("res://Scenes/CardNew.tscn").instance();
	
	new_card.card_name = props[CardPropNew.NAME].strip_edges();
	new_card.notch_flags = notches;
	new_card.card_id = gen_data.current_card_id;
#	for i in range(4):
#		var side = notches & 1 << i;
#		if (side > 0):
#			new_card.values[i] = 1;
#		else:
#			new_card.values[i] = -1;

#   Parse card effects
	var has_solo_effect = (props.size() <= CardPropNew.EFFECT_1) || (props[CardPropNew.CONDITION_2].strip_edges() == "");
	
	new_card.has_two_effects = !has_solo_effect;
	for i in range(2):
		var index;
		var d = {
			"condition" : CardNew.condition_animation_name.values().find(props[CardPropNew.CONDITION_1 + 3*i].strip_edges().to_lower()),
			"activation" : props[CardPropNew.ACTIVATION_1 + 3*i].strip_edges(),
			"effect" : props[CardPropNew.EFFECT_1 + 3*i].strip_edges(),
		}
		
		new_card.card_effects.append(d);
	
	var index = CardNew.attribute_animation_name.values().find(props[CardPropNew.ATTRIBUTE].strip_edges().to_lower());
	if (index == -1):
		printerr("Couldn't find attribute for card %d" % _id);
		new_card.queue_free();
		return;
	else:
		new_card.card_attribute = index;	
	
	new_card.card_value = int(props[CardPropNew.VALUE].strip_edges());
	
	new_card.position.x = (gen_data.current_card_id % CARDS_PER_LINE_DISPLAY) * 360;
	new_card.position.y = int(gen_data.current_card_id / CARDS_PER_LINE_DISPLAY) * 500;
	
	new_card.card_x = (gen_data.current_card_id % (CARD_PER_ROW * CARD_PER_COLUMN)) % CARD_PER_ROW;
	new_card.card_y = (gen_data.current_card_id % (CARD_PER_ROW * CARD_PER_COLUMN)) / CARD_PER_ROW;
	new_card.card_deck_id = 3 + int(gen_data.current_card_id / (CARD_PER_COLUMN * CARD_PER_ROW));
	new_card.card_export_id = new_card.card_deck_id * 100 + (gen_data.current_card_id % (CARD_PER_COLUMN * CARD_PER_ROW));
	
	gen_data.current_card_id += 1;
	get_tree().get_root().get_node("Board/CardDB").add_child(new_card);
	new_card.update_card();
	
	

#func _genetrate_card(props : Array, sides_flags : int, type: int, gen_data : Dictionary) -> Node2D:
#	var id = int(props[0].strip_edges());
#	var new_card : Card = preload("res://Scenes/Card.tscn").instance();
#	var index;
#	new_card.card_name = props[CardProp.NAME].strip_edges();
#
#	new_card.card_type = type;
#
#	#Sides :
#
#	new_card.notch_flags = sides_flags;
#	for i in range(4):
#		var side = sides_flags & 1 << i;
#		if (side > 0):
#			new_card.values[i] = 1;
#		else:
#			new_card.values[i] = -1;
#
#	index = Card.condition_animation_name.values().find(props[CardProp.CONDITION_TYPE].strip_edges().to_lower());
#
#	if (index == -1):
#		printerr("Couldn't find condition for card %d" % id);
#		new_card.queue_free();
#		return null;
#	else:
#		new_card.card_condition = index;
#
#	index = Card.attribute_animation_name.values().find(props[CardProp.ATTRIBUTE].strip_edges().to_lower());
#	if (index == -1):
#		printerr("Couldn't find attribute for card %d" % id);
#		new_card.queue_free();
#		return null;
#	else:
#		new_card.card_attribute = index;			
#
#	new_card.activation_text = props[CardProp.CONDITION_TEXT].strip_edges();
#	new_card.effect_text = props[CardProp.EFFECT_TEXT].strip_edges();
#
#	new_card.card_value = int(props[CardProp.VALUE].strip_edges());
#
#
#	new_card.card_id = id;
#
#	if (new_card):
#		new_card.position.x = (gen_data.counter % CARDS_PER_LINE_DISPLAY) * 360;
#		new_card.position.y = int(gen_data.counter / CARDS_PER_LINE_DISPLAY) * 500;
#
#		get_tree().get_root().get_node("Board/CardDB").add_child(new_card);
#		gen_data.counter +=1;
#
#	if(!CardDatabase.Data.has(id)):
#		CardDatabase.Data[id] = Dictionary();
#
#	if(!CardDatabase.Data[id].has(type)):
#		CardDatabase.Data[id][type] = Dictionary();
#
#	var value_to_use = 0;
#	match new_card.card_type:
#		Card.CardType.OFFENSE:
#			value_to_use = count_card_offense;
#			count_card_offense += 1;
#		Card.CardType.DEFENSE:
#			value_to_use = count_card_defense;
#			count_card_defense += 1;
#
#	new_card.card_x = (value_to_use % (CARD_PER_ROW * CARD_PER_COLUMN)) % CARD_PER_ROW;
#	new_card.card_y = (value_to_use % (CARD_PER_ROW * CARD_PER_COLUMN)) / CARD_PER_ROW;
#	new_card.card_deck_id = 3 + int(value_to_use / (CARD_PER_COLUMN * CARD_PER_ROW));
#	new_card.card_export_id = new_card.card_deck_id * 100 + (value_to_use % (CARD_PER_COLUMN * CARD_PER_ROW));
#
#	CardDatabase.Data[id][type][sides_flags] = new_card;
#
#	return new_card;
#


	
	
func _on_Import_pressed() -> void:
	CardDatabase.Data.clear();
	var path = Constants.MasterDeckPath;
	var f:File = File.new();
	var err:int = f.open(path, File.READ);
	
	if (!err):	
		var cardDB : Node2D = get_tree().get_root().get_node("Board/CardDB"); 
		
		for child in cardDB.get_children():
			child.queue_free();
			
		var count_card = 0;
		var nb_line = 0;
		
		CardDatabase.export_hash = f.get_md5(path);
		
		var gen_data = Dictionary();
		gen_data.current_card_id = 0;
		var lines_parsed = 0;
		#skip first line
		f.get_csv_line();
		while(!f.eof_reached()):
			var line = f.get_csv_line();
			lines_parsed += 0;
			
			var nb_notches = int(line[CardPropNew.NOTCHES].strip_edges());
			
			match nb_notches:
				0:
					_generate_card_new(line, 0, gen_data);
				1: 
					_generate_card_new(line, 0x1,gen_data);
					_generate_card_new(line, 0x2,gen_data);
					_generate_card_new(line, 0x4,gen_data);
					_generate_card_new(line, 0x8,gen_data);
				2: 
					_generate_card_new(line, 0x1 | 0x02,gen_data);
					_generate_card_new(line, 0x1 | 0x04,gen_data);
					_generate_card_new(line, 0x1 | 0x08,gen_data);
					_generate_card_new(line, 0x2 | 0x04,gen_data);
					_generate_card_new(line, 0x2 | 0x08,gen_data);
					_generate_card_new(line, 0x4 | 0x08,gen_data);
				3:
					_generate_card_new(line, 0xF ^ 0x1,gen_data);
					_generate_card_new(line, 0xF ^ 0x2,gen_data);
					_generate_card_new(line, 0xF ^ 0x4,gen_data);
					_generate_card_new(line, 0xF ^ 0x8,gen_data);
				4:
					_generate_card_new(line, 0xF, gen_data);
				_:
					printerr("Too Much sides");
	AppState.import_done = true;

#func _on_Imoprt_pressed_old() -> void:
#	CardDatabase.Data.clear();
#	var path = "import/import.cdb";
#	var f:File = File.new();
#	var err:int = f.open(path, File.READ);
#
#	var cardDB : Node2D = get_tree().get_root().get_node("Board/CardDB");
#
#	count_card_offense = 0;
#	count_card_defense = 0;
#
#	if (!err):
#		# Remove all children of card db
#		for child in cardDB.get_children():
#			child.queue_free();
#
#		var counter = 0;
#		var nb_line = 0;
#
#		var gen_data = {
#			counter = 0,
#		};
#
#		var id = 0;
#		CardDatabase.export_hash = f.get_md5(path);
#
#		# Skip first line
#		f.get_csv_line();
#		while(!f.eof_reached()):
#			var index;
#			var line = f.get_csv_line();
#			nb_line += 1;
#
#			if (line.size() != CardProp.COUNT):
#				printerr("Line %d in %s is illformed, skipping" % [nb_line, path]);
#				continue;
#			var nb_notches = int(line[CardProp.NOTCH_COUNT].strip_edges());
#
#			var types = Array();
#
#			match line[CardProp.TYPE].strip_edges().to_lower():
#				"offense":
#					types.append(Card.CardType.OFFENSE);
#				"defense":
#					types.append(Card.CardType.DEFENSE);
#				"hybrid":
#					types.append(Card.CardType.OFFENSE);
#					types.append(Card.CardType.DEFENSE);
#
#			id = int(line[CardProp.SHEET_ID].strip_edges());
#
#			for type in types:
#				match nb_notches:
#					0:
#						_genetrate_card(line, 0, type, gen_data);
#					1: 
#						_genetrate_card(line, 0x1, type, gen_data);
#						_genetrate_card(line, 0x2, type, gen_data);
#						_genetrate_card(line, 0x4, type, gen_data);
#						_genetrate_card(line, 0x8, type, gen_data);
#					2: 
#						_genetrate_card(line, 0x1 | 0x02, type, gen_data);
#						_genetrate_card(line, 0x1 | 0x04, type, gen_data);
#						_genetrate_card(line, 0x1 | 0x08, type, gen_data);
#						_genetrate_card(line, 0x2 | 0x04, type, gen_data);
#						_genetrate_card(line, 0x2 | 0x08, type, gen_data);
#						_genetrate_card(line, 0x4 | 0x08, type, gen_data);
#					3:
#						_genetrate_card(line, 0xF ^ 0x1, type, gen_data);
#						_genetrate_card(line, 0xF ^ 0x2, type, gen_data);
#						_genetrate_card(line, 0xF ^ 0x4, type, gen_data);
#						_genetrate_card(line, 0xF ^ 0x8, type, gen_data);
#					4:
#						_genetrate_card(line, 0xF, type, gen_data);
#					_:
#						printerr("Too Much sides");
#	else:
#		printerr("Couldn't open file %s. Error %d" % [path, err]);
#
#	f.close();	

func _on_Download_pressed() -> void:
	var error = OS.execute("Wget/dl.bat", [], true);
	
	#var error = $HTTPRequest.request(url, PoolStringArray( ), false, HTTPClient.METHOD_GET);
	print(error);

func _on_LineEdit_text_entered(new_text: String) -> void:
	pass # Replace with function body.
