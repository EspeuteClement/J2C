extends Button


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Export_pressed() -> void:
	var dir := Directory.new();
	dir.open("user://decks");
	if !dir.dir_exists("out_decks"):
		dir.make_dir("out_decks");

	var in_path = dir.get_current_dir() + "/";
	var out_path = in_path + "out_decks/";
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		if dir.current_is_dir():
			print("Found directory: " + file_name)
		else:
			print("Found file: " + file_name)
			get_tree().root.get_node("Board/Control/Viewport/RenderCam")._save_custom_deck(in_path + file_name, file_name);
		file_name = dir.get_next()
	
	pass # Replace with function body.
