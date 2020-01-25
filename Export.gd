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



func export_card(card : CardNew, out_name : String) -> void:
	#remove all other cards
	for node in get_children():
		node.queue_free();
		remove_child(node);
	
	var dupe = card.duplicate(0);
	dupe.card_effects = card.card_effects;
	
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



func export_batch(nodes: Array, out_name: String, db:Dictionary):
	var popup = preload("res://Scenes/PopupDialog.tscn").instance();
	get_tree().root.add_child(popup);
	
	popup.popup_exclusive = true;
	popup.popup();
	
	randomize()
	for child in get_children():
		remove_child(child);
		child.queue_free();
		
	var size = preload("res://Assets/Card/template_off.png").get_size()*scalefactor;	
	get_viewport().set_size(size*AppState.tiles_size);
	
	var current_deck;
	var image_name;
	
	var i = 0;
	var nb_gen = 0;
	var max_nodes = nodes.size();
	for c in range(max_nodes):
		popup.progress = c * 100 / max_nodes;
		if (c % int(AppState.tiles_size.x * AppState.tiles_size.y) == 0):
			image_name = "%s_%s_%d.png" % [out_name, CardDatabase.export_hash, nb_gen+3];
		
		var node = nodes[c] as CardNew;
		if (node):
			var dupe = node.duplicate(0xF);
#			dupe.values = node.values;
			add_child(dupe);
			dupe.position = size/2 + size * Vector2(i%int(AppState.tiles_size.x), int(i/AppState.tiles_size.y));
			dupe.scale = scalefactor;
			
			_add_new_card_id(db, dupe);
		
		if (i == AppState.tiles_size.x * AppState.tiles_size.y - 1 || c == nodes.size()-1):
			get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			var img = get_viewport().get_texture().get_data();
			img.save_png("%s/%s" % [Constants.MasterDeckDirPath, image_name]);
			
			nb_gen += 1;
			i = 0;
			
			for child in get_children():
				remove_child(child);
				child.queue_free();
		else:
			i += 1
	popup.queue_free();
	

var CardTemplateObject = null;

func _create_deck_export_data() -> Dictionary:
	var file := File.new()
	file.open("res://Assets/DeckTemplates/DeckTemplate.json", file.READ)
	var text = file.get_as_text()
	var dict := JSON.parse(text).get_result() as Dictionary;
	dict.ObjectStates[0].DeckIDs.clear();
	dict.ObjectStates[0].CustomDeck.clear();
	return dict;


func _notch_flags_to_name(flags: int) -> String:
	var name = "";
	if (flags & (1<<CardNew.Dir.Right) > 0):
		name += "R";
	if (flags & (1<<CardNew.Dir.Top) > 0):
		name += "T";
	if (flags & (1<<CardNew.Dir.Left) > 0):
		name += "L";
	if (flags & (1<<CardNew.Dir.Down) > 0):
		name += "D";
	
	return name;
	
func _add_new_card_id(db:Dictionary, card:Node) -> Dictionary:
	
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
	card_obj.Nickname = "%s (%s) [%s]" % [card.card_name, CardNew.attribute_animation_name[card.card_attribute].capitalize() , _notch_flags_to_name(card.notch_flags)];
	card_obj.Description = "%d, %d, x:%d, y:%d" % [card.card_export_id, card.card_deck_id, card.card_x, card.card_y];
	card_obj.CustomDeck = Dictionary();
	var the_deck = AppState.deck_db[deck_id].duplicate();
	card_obj.CustomDeck[str(deck_id)] = the_deck;
	
	(db.ObjectStates[0].DeckIDs as Array).append(card_id);
	
	db.ObjectStates[0]["ContainedObjects"].append(card_obj);
	
	if !db.ObjectStates[0]["CustomDeck"].has(str(deck_id)):
		db.ObjectStates[0]["CustomDeck"][str(deck_id)] = the_deck;
		
	return db;

func _save_card_db(db:Dictionary, out_name:String):
	var deck_export = File.new();
	deck_export.open("%s.json" % out_name, File.WRITE_READ);
	deck_export.store_string(JSON.print(db, "  "));
	deck_export.close();
	
	var path;

	path = "res://Assets/Card/card_back_offense.png";
	
	var dir = Directory.new()
	dir.copy(path, "%s.png" % out_name);

func _on_Export_pressed() -> void:
	
	
	var count:int = 0;
	var nb_batch:int = 0;
	var batch := Array();

	var children = $"../../../CardDB".get_children();
	var count_batch:int = 0;
	
	for node in children:
		if node is CardNew:
			batch.append(node);
			count += 1;
#			pb.value = float(count) / float(children.size());
			
	var db = _create_deck_export_data();
	
#	Clear out the output directory
	var Dir = Directory.new();
	Dir.open(Constants.MasterDeckDirPath)
	Dir.list_dir_begin()
	var file_name = Dir.get_next()
	while (file_name != ""):
		if !Dir.current_is_dir():
			Dir.remove(file_name);
		file_name = Dir.get_next()
		
	Dir.list_dir_end();
	
	export_batch(batch,  Constants.MasterDeckImageName, db);

	_save_card_db(db, Constants.MasterDeckOutPath);
	

	pass # Replace with function body.

var tiled = false;

func _save_custom_deck(in_name:String, out_name:String):
	var path = in_name;
	var f:File = File.new();
	var err:int = f.open(path, File.READ);
	
	if (err):
		printerr("Couldn't open file %s" % in_name);
		return;
	var line;
#	DL header
	f.get_csv_line();
#	Info headers
	f.get_csv_line();	
	var db = _create_deck_export_data();
	
	while(!f.eof_reached()):
		line = f.get_csv_line();
		var id = int(line[0].strip_edges());
		if (!id): continue;
		var notches_txt = line[1].strip_edges();
		if (!notches_txt): continue;
		var notch_id = 0;
		for c in notches_txt:
			match c.to_upper():
				"R", ">", "6":
					notch_id += 1 << CardNew.Dir.Right;
				"T", "^", "8":
					notch_id += 1 << CardNew.Dir.Top;
				"L", "<", "4":
					notch_id += 1 << CardNew.Dir.Left;
				"D", "V", "2":
					notch_id += 1 << CardNew.Dir.Down;
				_:
					printerr("Notch char not recognized");
					
		_add_new_card_id(db, CardDatabase.Data[id][notch_id]);
	
	_save_card_db(db, out_name);

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
	#_save_custom_deck("import/import9.cdb", "Blank example");
	
	
	
	
	
