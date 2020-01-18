extends Label

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var dir : Directory;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dir = Directory.new();
	dir.open("user://");
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (AppState.master_deck_ok):
		text = Constants.MasterDeckName +" : OK";
	else:
		text = Constants.MasterDeckName +" : File missing";
		
	pass
