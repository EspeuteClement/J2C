extends Button


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export(bool) var is_deck_download = false;

var request : HTTPRequest = null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var timer = 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (request):
		disabled = true;
		timer += delta;
		var s = "Downloading ";
		for i in range(int(fmod(timer, 4))):
			s += ".";
		text = s + " (%d)" % request.get_http_client_status();
	elif is_deck_download && AppState.download_deck_name.length() == 0:
		disabled = true;
	else:
		disabled = false;
		text = "Download"

var url;
var download_file_name;

func _on_Download_pressed() -> void:
	if request != null:
		return;
	
	timer = 0;
	request = HTTPRequest.new();
	add_child(request)
	
	request.connect("request_completed", self, "_http_request_completed")
	# Perform the HTTP request. The URL below returns some JSON as of writing.
	
	if (!is_deck_download):
		request.set_download_file(Constants.MasterDeckPath)
		url = "https://docs.google.com/spreadsheets/d/%s/export?gid=%s&format=csv&id=%s" % [AppState.master_sheet_code, AppState.master_sheet_gid, AppState.master_sheet_code];
	else:
		download_file_name = "%s%s.csv" % [Constants.DecksPath,
			AppState.download_deck_name];
		request.set_download_file(download_file_name);
		url = "https://docs.google.com/spreadsheets/d/%s/export?gid=%s&format=csv&id=%s" % [AppState.download_deck_code, AppState.download_deck_gid, AppState.download_deck_code];
	
	var error = request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	print("Request launched : %s" % url);
	pass # Replace with function body.

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	print("Request finished");	
	
#	Add url to the downloaded file so we can downloadit again later
	if (is_deck_download):
		var file_location = download_file_name;
		var file = File.new();
		var err = file.open(file_location, File.READ_WRITE);
		if (!err):
			var whole_file = file.get_as_text();
			
			file.store_line(url);
			file.store_string(whole_file);
			file.close();
	request.queue_free();
	request = null;
