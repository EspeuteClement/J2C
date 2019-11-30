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

const scalefactor = Vector2(0.75,0.75);
const tiles_size = Vector2(6,6);

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
	for child in get_children():
		remove_child(child);
		child.queue_free();
		
	var size = preload("res://Assets/Card/template_off.png").get_size()*scalefactor;	
	get_viewport().set_size(size*tiles_size);

	
	var i = 0;
	var nb_gen = 0;
	for c in range(nodes.size()):
		var node = nodes[c];
		if (node):
			var dupe = node.duplicate();
			dupe.values = node.values;
			add_child(dupe);
			dupe.position = size/2 + size * Vector2(i%int(tiles_size.x), int(i/tiles_size.y));
			dupe.scale = scalefactor;
			
			_add_new_card_id(db, i, nb_gen);
		
		if (i == tiles_size.x * tiles_size.y - 1 || c == nodes.size()-1):
			get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			var img = get_viewport().get_texture().get_data();
			var image_name = "%s_%d.png" % [out_name, nb_gen];
			img.save_png("user://%s" % image_name);
			_add_new_deck(db, nb_gen, image_name, type);
			
			nb_gen += 1;
			i = 0;
			
			for child in get_children():
				remove_child(child);
				child.queue_free();
		else:
			i += 1

func _create_deck_export_data() -> Dictionary:
	var file := File.new()
	file.open("res://Assets/DeckTemplates/DeckTemplate.json", file.READ)
	var text = file.get_as_text()
	var dict := JSON.parse(text).get_result() as Dictionary;
	dict.ObjectStates[0].DeckIDs.clear();
	dict.ObjectStates[0].CustomDeck.clear();
	return dict;

const FILE_HOST_URL = "http://clementespeute.com/res/";

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
	dict.BackIsHidden = false;
	dict.UniqueBack = false;
	
	return db;
	
func _add_new_card_id(db:Dictionary, card_pos:int, deck_id:int) -> Dictionary:
	if !db.ObjectStates[0].has("DeckIDs"):
		db.ObjectStates[0].DeckIDs = Array();
	
	var x = card_pos % int(tiles_size.x);
	var y = int(card_pos / int(tiles_size.x));
	
	
	(db.ObjectStates[0].DeckIDs as Array).append(deck_id+3 * 100 + y * 10 + x);
	
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
	var pb = $"../../../CanvasLayer/ProgressBar";
	pb.visible = true;
	pb.percent_visible = true;
	pb.value = 0;
	pb.min_value = 0;
	pb.max_value = 1.0;
	

	
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
		_save_card_db(db, "Master Deck Defense", Card.CardType.DEFENSE);
		
	pb.visible = false;
	OS.shell_open(str("file://", OS.get_user_data_dir()));
	pass # Replace with function body.

var tiled = false;

func _on_CheckBox_toggled(button_pressed: bool) -> void:
	tiled = button_pressed;
	pass # Replace with function body.
