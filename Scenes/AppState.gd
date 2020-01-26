extends Node

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var import_done = false;
var master_deck_ok = false;

var master_sheet_gid = "1339057682";
var master_sheet_code = "1o7K6qs4PkOApoRXCfQgh5xbE5y-aXSAl2VRxwKNk-3w";

var download_deck_gid = "224497149"
var download_deck_code = "1o7K6qs4PkOApoRXCfQgh5xbE5y-aXSAl2VRxwKNk-3w";
var download_deck_name = "";

var current_selected_file_list_string = "";


var deck_db : Dictionary;

const tiles_size = Vector2(6,6);


func _add_new_deck(id:int, face_card_file:String) -> Dictionary:
	
	if (deck_db.has(id)):
		return deck_db[id];
		
	var dict = Dictionary();
	deck_db[id] = dict;
	dict.FaceURL = Constants.FILE_HOST_URL + face_card_file;
	dict.BackURL = Constants.FILE_HOST_URL + "card_back.png";
	
	dict.NumWidth = tiles_size.x;
	dict.NumHeight = tiles_size.y;
	dict.BackIsHidden = true;
	dict.UniqueBack = false;
	
	return dict;

var _dir : Directory;

var DeckDir : Directory;

func _create_dir_if_not_exist(path : String):
	if !_dir.dir_exists(path):
		_dir.make_dir(path);

var popup : PopupDialog;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	deck_db.clear();
	
	_dir = Directory.new();
	_dir.open("user://");
	
	_create_dir_if_not_exist(Constants.ImagesPaths);
	_create_dir_if_not_exist(Constants.DecksPath);
	_create_dir_if_not_exist(Constants.MasterDeckDirPath);
	
	DeckDir= Directory.new();
	DeckDir.open(Constants.DecksPath);
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	master_deck_ok = _dir.file_exists(Constants.MasterDeckName)
	pass
	
func delete_current_deck():
	DeckDir.remove(AppState.current_selected_file_list_string);
