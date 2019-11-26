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

func export_batch(nodes: Array, type:int, out_name: String):
	for child in get_children():
		remove_child(child);
		child.queue_free();
		
	var size = preload("res://Assets/Card/template_off.png").get_size()*scalefactor;	
	get_viewport().set_size(size*tiles_size);
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	
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
		
		if (i == tiles_size.x * tiles_size.y - 2 || c == nodes.size()-1):
			var back = Sprite.new();
			match type:
				Card.CardType.OFFENSE:
					back.texture = preload("res://Assets/Card/card_back_offense.png");
				Card.CardType.DEFENSE:
					back.texture = preload("res://Assets/Card/card_back_defense.png");
			
			back.position = size/2 + size * Vector2(tiles_size.x-1, int(tiles_size.y-1));
			#back.scale = scalefactor;
			add_child(back);
			
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			var img = get_viewport().get_texture().get_data();
			img.save_png("user://%s_%d.png" % [out_name, nb_gen]);
			nb_gen += 1;
			i = 0;
		else:
			i += 1

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
		export_batch(batch_off, Card.CardType.OFFENSE,  "cards_batch_off");
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		export_batch(batch_def, Card.CardType.DEFENSE, "cards_batch_def");
	pb.visible = false;
	OS.shell_open(str("file://", OS.get_user_data_dir()));
	pass # Replace with function body.

var tiled = false;

func _on_CheckBox_toggled(button_pressed: bool) -> void:
	tiled = button_pressed;
	pass # Replace with function body.
