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

func export_card(card : Card, out_name : String) -> void:
	#remove all other cards
	for node in $"..".get_children():
		if node is Card:
			node.queue_free();
	
	
	var dupe = card.duplicate();
	add_child(dupe);
	
	var size = dupe.get_node("CardTemplate").texture.get_size();
	get_viewport().set_size(size);
	dupe.position = size/2;
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var img = get_viewport().get_texture().get_data();
	img.save_png("export/%s.png" % out_name);
	pass # Replace with function body.

func _on_Export_pressed() -> void:
	var count:int = 0;
	for node in $"../../../".get_children():
		if node is Card:
			export_card(node, "card%04d" % count);
			count += 1;
	pass # Replace with function body.