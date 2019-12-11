extends Camera2D

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

const scalefactor = Vector2(1.0,1.0);
const tiles_size = Vector2(6,6);

var deck_db : Array;

func export_card(card : Card, out_name : String) -> void:
	#remove all other cards
	for node in get_children():
		node.queue_free();
		remove_child(node);
	
	var dupe = card.duplicate();
	dupe.values = card.values;
	add_child(dupe);
	
	var size = preload("res://Assets/Card/CardTemplate.png").get_size();
	get_viewport().set_size(size*scalefactor);
	dupe.position = size/2*scalefactor;
	dupe.scale = scalefactor;
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var img = get_viewport().get_texture().get_data();
	img.save_png("user://%s.png" % out_name);

	
	pass # Replace with function body.



func export_batch(nodes: Array, type:int, out_name: String, db:Dictionary):
	randomize()
	for child in get_children():
		remove_child(child);
		child.queue_free();
		
	var size = preload("res://Assets/Card/template_off.png").get_size()*scalefactor;	
	get_viewport().set_size(size*tiles_size);

	
	var current_deck;
	var image_name;
	
	var i = 0;
	var nb_gen = 0;
	for c in range(nodes.size()):
		if (c % int(tiles_size.x * tiles_size.y) == 0):
			image_name = "%s_%s_%d.png" % [out_name, CardDatabase.export_hash, nb_gen];
			current_deck = _add_new_deck(db, nb_gen, image_name, type);
			deck_db[type].append(current_deck);
		
		var node = nodes[c];
		if (node):
			var dupe = node.duplicate();
			dupe.values = node.values;
			add_child(dupe);
			dupe.position = size/2 + size * Vector2(i%int(tiles_size.x), int(i/tiles_size.y));
			dupe.scale = scalefactor;
			
			_add_new_card_id(db, dupe);
		
		if (i == tiles_size.x * tiles_size.y - 1 || c == nodes.size()-1):
			get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			var img = get_viewport().get_texture().get_data();
			img.save_png("user://%s" % image_name);
			
			nb_gen += 1;
			i = 0;
			
			for child in get_children():
				remove_child(child);
				child.queue_free();
		else:
			i += 1

var CardTemplateObject = null;

func _create_deck_export_data() -> Dictionary:
	var file := File.new()
	file.open("res://Assets/DeckTemplates/DeckTemplate.json", file.READ)
	var text = file.get_as_text()
	var dict := JSON.parse(text).get_result() as Dictionary;
	dict.ObjectStates[0].DeckIDs.clear();
	dict.ObjectStates[0].CustomDeck.clear();
	return dict;

const FILE_HOST_URL = "http://clementespeute.com/res/";

func _notch_flags_to_name(flags: int) -> String:
	var name = "";
	if (flags & (1<<Card.Dir.Right) > 0):
		name += "R";
	if (flags & (1<<Card.Dir.Top) > 0):
		name += "T";
	if (flags & (1<<Card.Dir.Left) > 0):
		name += "L";
	if (flags & (1<<Card.Dir.Down) > 0):
		name += "D";
	
	return name;

func _add_new_deck(db:Dictionary, id:int, face_card_file:String, type:int) -> Dictionary:
	var deck_name = (id+3);
	
	
	if (db.ObjectStates[0].CustomDeck.has(deck_name)):
		return db;
		
	var dict = Dictionary();
	db.ObjectStates[0].CustomDeck[deck_name] = dict;
	dict.FaceURL = FILE_HOST_URL + face_card_file;
	match type:
		Card.CardType.OFFENSE:
			dict.BackURL = FILE_HOST_URL + "card_back_offense.png";
		Card.CardType.DEFENSE:
			dict.BackURL = FILE_HOST_URL + "card_back_defense.png";
	
	dict.NumWidth = tiles_size.x;
	dict.NumHeight = tiles_size.y;
	dict.BackIsHidden = true;
	dict.UniqueBack = false;
	
	return dict;
	
func _add_new_card_id(db:Dictionary, card:Card) -> Dictionary:
	
	if !CardTemplateObject:
		var file := File.new()
		file.open("res://Assets/DeckTemplates/CardTemplate.json", file.READ)
		var text = file.get_as_text();
		CardTemplateObject = JSON.parse(text).get_result() as Dictionary;
	
	if !db.ObjectStates[0].has("DeckIDs"):
		db.ObjectStates[0].DeckIDs = Array();
		
	if !db.ObjectStates[0].has("ContainedObjects"):
		db.ObjectStates[0]["ContainedObjects"] = Array();
	
	var card_obj = CardTemplateObject.duplicate(true);
	
	var x = card.card_x;
	var y = card.card_y;
	
	var deck_id = card.card_deck_id;
	
	var card_id = card.card_export_id;	
	card_obj.CardID = card_id;
	card_obj.Nickname = "%s (%s) [%s]" % [card.card_name, Card.attribute_animation_name[card.card_attribute].capitalize() , _notch_flags_to_name(card.notch_flags)];
	card_obj.Description = "%d, %d, x:%d, y:%d" % [card.card_export_id, card.card_deck_id, card.card_x, card.card_y];
	card_obj.CustomDeck = Dictionary();
	var the_deck = deck_db[card.card_type][deck_id-3].duplicate();
	card_obj.CustomDeck[str(deck_id+3)] = the_deck;
	
	(db.ObjectStates[0].DeckIDs as Array).append(card_id);
	
	db.ObjectStates[0]["ContainedObjects"].append(card_obj);
	return db;

func _save_card_db(db:Dictionary, out_name:String, type:int):
	var deck_export = File.new();
	deck_export.open("user://%s.json" %out_name, File.WRITE_READ);
	deck_export.store_string(JSON.print(db, "  "));
	deck_export.close();
	
	var path;
	match type:
		Card.CardType.OFFENSE:
			path = "res://Assets/Card/card_back_offense.png";
		Card.CardType.DEFENSE:
			path = "res://Assets/Card/card_back_defense.png";
	
	var dir = Directory.new()
	dir.copy(path, "user://%s.png" % out_name);

func _on_Export_pressed() -> void:
	var pb = $"../../../CanvasLayer/Panel/VBoxContainer/ProgressBar";
	pb.visible = true;
	pb.percent_visible = true;
	pb.value = 0;
	pb.min_value = 0;
	pb.max_value = 1.0;
	
	deck_db = [Array(), Array()];
	
	var count:int = 0;
	var nb_batch:int = 0;
	var batch_off := Array();
	var batch_def := Array();
	var children = $"../../../CardDB".get_children();
	var count_batch:int = 0;
	
	var current_type = Card.CardType.OFFENSE;
	
	for node in children:
		if node is Card:
			if !tiled:
				export_card(node, "(%03d) - %s" % [count, node.card_name]);
				yield(get_tree(), "idle_frame")
				yield(get_tree(), "idle_frame")
			if tiled:
				match node.card_type:
					Card.CardType.OFFENSE:
						batch_off.append(node);
					Card.CardType.DEFENSE:
						batch_def.append(node);
			count += 1;
			pb.value = float(count) / float(children.size());
			
	if tiled:
		var db = _create_deck_export_data();
		export_batch(batch_off, Card.CardType.OFFENSE,  "cards_batch_off", db);
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		_save_card_db(db, "Master Deck Offense", Card.CardType.OFFENSE);		
		db = _create_deck_export_data();
		export_batch(batch_def, Card.CardType.DEFENSE, "cards_batch_def", db);
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		_save_card_db(db, "Master Deck Defense", Card.CardType.DEFENSE);
		
	pb.visible = false;
	
	OS.shell_open(str("file://", OS.get_user_data_dir()));
	pass # Replace with function body.

var tiled = false;

func _save_custom_deck(in_name:String, out_name:String):
	var path = in_name;
	var f:File = File.new();
	var err:int = f.open(path, File.READ);
	
	if (err):
		printerr("Couldn't open file %s" % in_name);
		return;
	
	var line = f.get_csv_line();
	
	var type = 0;
	var type_str = line[0].strip_edges().to_lower();
	if (type_str == "defense"): type = 1;
	
	f.get_csv_line();
	var db = _create_deck_export_data();
	
	while(!f.eof_reached()):
		line = f.get_csv_line();
		var id = int(line[0].strip_edges());
		var notches_txt = line[1].strip_edges();
		var notch_id = 0;
		for c in notches_txt:
			match c.to_upper():
				"R", ">":
					notch_id += 1 << Card.Dir.Right;
				"T", "^":
					notch_id += 1 << Card.Dir.Top;
				"L", "<":
					notch_id += 1 << Card.Dir.Left;
				"D", "V":
					notch_id += 1 << Card.Dir.Down;
				"_":
					printerr("Notch char not recognized");
					
		_add_new_card_id(db, CardDatabase.Data[id][type][notch_id]);
	
	var did = 3;
	for deck in deck_db[type]:
		db.ObjectStates[0].CustomDeck[str(did)] = deck;
		did += 1;
	
	_save_card_db(db, out_name, type);

func _on_CheckBox_toggled(button_pressed: bool) -> void:
	tiled = button_pressed;
	pass # Replace with function body.


func _on_SaveDecks_pressed() -> void:
	_save_custom_deck("import/import1.cdb", "Custom Offense 1");
	_save_custom_deck("import/import2.cdb", "Custom Defense 1");
	_save_custom_deck("import/import3.cdb", "Canonic Offense");
	_save_custom_deck("import/import4.cdb", "Canonic Defense");
	_save_custom_deck("import/import5.cdb", "Phoenix Fire Offense");
	_save_custom_deck("import/import6.cdb", "Phoenix Fire Defense");
	_save_custom_deck("import/import7.cdb", "Geothermal Energy Offense");
	_save_custom_deck("import/import8.cdb", "Geothermal Energy Defense");
	
	
	
	
	
