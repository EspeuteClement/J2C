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


func _on_Delete_pressed() -> void:
	AppState.delete_current_deck();
	pass # Replace with function body.