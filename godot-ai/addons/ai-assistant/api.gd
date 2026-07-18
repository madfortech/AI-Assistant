@tool
extends Node
class_name AIApi

signal response_received(text: String, plan: String, credits: int)
signal request_failed(error: String)
signal user_loaded(name: String, plan: String, credits: int)

func get_api_url() -> String:
	var base_url := AISettings.load_url()
	return base_url + "/generate"

func get_api_key() -> String:
	return AISettings.load_key()
	
var http: HTTPRequest
var current_action := ""

func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)

func load_user() -> void:
	current_action = "me"
	var api_key := get_api_key()

	if api_key.is_empty():
		request_failed.emit("Please enter your Unique Key from Settings.")
		return
	var headers: PackedStringArray = [
		"Accept: application/json",
		"Authorization: Bearer " + api_key
		 
	]

 
	var url := get_api_url().replace("/generate", "/me")

	var err := http.request(
	url,
	headers,
	HTTPClient.METHOD_GET
	)

	if err != OK:
		request_failed.emit("Unable to load user information.")

	
	
func send_message(message: String) -> void:
	
	var api_key := get_api_key()

	if api_key.is_empty():
		request_failed.emit("Please enter your Unique Key from Settings.")
		return
		
	var data := {
		"prompt": message
	}

	var json := JSON.stringify(data)

	var headers: PackedStringArray = [
		"Content-Type: application/json",
		"Accept: application/json",
		"Authorization: Bearer " + api_key
		
	]
	
	current_action = "generate"
	var err := http.request(
		get_api_url(),
		headers,
		HTTPClient.METHOD_POST,
		json
	)
	
	
	if err != OK:
		request_failed.emit("Unable to send your request. Please try again.")


func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	
	
	
	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("Network error. Please check your connection.")
		return

	if response_code != 200:
		request_failed.emit("Server Error " + str(response_code))
		return
	
	var response_text := body.get_string_from_utf8()
	var json := JSON.new()
	var parse_error := json.parse(response_text)

	if parse_error != OK:
		request_failed.emit("Received an invalid response from the server.")
		return

	var data: Dictionary = json.data

	# Handle /api/me response
	if current_action == "me":
		var name := str(data.get("name", "User"))
		var plan := str(data.get("plan", "Free"))
		var credits := int(data.get("credits_remaining", 0))
		
		user_loaded.emit(name, plan, credits)
		return
	
	# Handle /api/generate response
	var text := str(data.get("text", "")).strip_edges()

	if text.is_empty():
		request_failed.emit("The server returned an empty response.")
		return	
		
	var plan := str(data.get("plan", "Free"))
	var credits := int(data.get("credits_remaining", 0))

	response_received.emit(text, plan, credits)
	
