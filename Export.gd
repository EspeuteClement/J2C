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

func export_card(card : Card, out_name : String) -> void:
	#remove all other cards
	for node in $"..".get_children():
		if node is Card:
			node.queue_free();
			$"..".remove_child(node);
	
	
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

func _on_Export_pressed() -> void:
	var pb = $"../../../CanvasLayer/ProgressBar";
	pb.visible = true;
	pb.percent_visible = true;
	pb.value = 0;
	pb.min_value = 0;
	pb.max_value = 1.0;
	
	var count:int = 0;
	var children = $"../../../CardDB".get_children();
	for node in children:
		if node is Card:
			export_card(node, "(%03d) - %s" % [count, node.card_name]);
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			count += 1;
			pb.value = float(count) / float(children.size());
	pb.visible = false;
	OS.shell_open(str("file://", OS.get_user_data_dir()));
	pass # Replace with function body.
