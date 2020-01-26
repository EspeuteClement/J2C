extends LineEdit

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


var reg = RegEx;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reg = RegEx.new();
	reg.compile("docs.google.com\\/spreadsheets\\/d\\/([a-zA-Z\\-0-9]+)\\/edit#gid=([0-9]+)");
	pass # Replace with function body.

func _on_DeckUrlDownload_text_changed(new_text: String) -> void:
	var result : RegExMatch = reg.search(new_text);
	
	if (!result):
		AppState.download_deck_code = null;
		AppState.download_deck_gid = null;
		printerr("Could't match shit'")
		return;
	
	AppState.download_deck_code = result.get_string(1);
	AppState.download_deck_gid = result.get_string(2);
	
	print("parsed %s, %s" % [AppState.download_deck_code, AppState.download_deck_gid]);
	
	pass # Replace with function body.
