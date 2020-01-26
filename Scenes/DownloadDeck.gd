extends HTTPRequest

onready var download_button = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("request_completed", self, "_on_HTTPRequest_request_completed");
	pass # Replace with function body.

var timing = 0.0;

func _process(delta: float) -> void:
	timing += delta;
	
	if get_http_client_status() != 0:
		download_button.disabled = true;
		var s = "Downloading ";
		for i in range(int(fmod(timing, 4))):
			s += ".";
		download_button.text = s + " (%d)" % get_http_client_status();
	else:
		var s = "Download";
		download_button.text = s;
		download_button.disabled = false;
	
func _on_Download_pressed():
	set_download_file(Constants.MasterDeckPath + "%s[%s].csv" % [AppState.download_deck_code, AppState.download_deck_gid]);
	print(request("http://docs.google.com/spreadsheets/d/%s/export?gid=%s&format=csv&id=%s" % [AppState.master_sheet_code, AppState.master_sheet_gid, AppState.master_sheet_code]))
	print("Request launched");

func _on_HTTPRequest_request_completed( result, response_code, headers, body ):
	print(response_code)
