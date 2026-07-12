@tool
extends Node
class_name AIApi

signal response_received(text: String)
signal request_failed(error: String)

const API_URL := "https://aiassistant.test/api/generate"

var http: HTTPRequest


func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)


func send_message(message: String) -> void:
	var data := {
		"prompt": message
	}

	var json := JSON.stringify(data)

	var headers: PackedStringArray = [
		"Content-Type: application/json",
		"Accept: application/json"
	]

	var err := http.request(
		API_URL,
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
		request_failed.emit("The server couldn't process your request.")
		return

	var response_text := body.get_string_from_utf8()

	var json := JSON.new()
	var parse_error := json.parse(response_text)

	if parse_error != OK:
		request_failed.emit("Received an invalid response from the server.")
		return

	var data: Dictionary = json.data

	var text := str(data.get("text", "")).strip_edges()

	if text.is_empty():
		request_failed.emit("The server returned an empty response.")
		return

	response_received.emit(text)
