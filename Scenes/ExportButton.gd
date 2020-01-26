extends Button


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (AppState.current_selected_file_list_string != ""):
		disabled = false;
	else:
		disabled = true;
	pass


func _on_Export_pressed() -> void:
	get_tree().root.get_node("Board/Control/Viewport/RenderCam")\
	._save_custom_deck(Constants.DecksPath + AppState.current_selected_file_list_string, AppState.current_selected_file_list_string);
	pass # Replace with function body.
