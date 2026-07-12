@tool
extends Control

const AIApi = preload("res://addons/ai-assistant/api.gd")

@onready var title: Label = $MarginContainer/VBoxContainer/Header/Title
@onready var chat_history: RichTextLabel = $MarginContainer/VBoxContainer/Conversation
@onready var prompt: LineEdit = $MarginContainer/VBoxContainer/Prompt
@onready var send_button: Button = $MarginContainer/VBoxContainer/BottomBar/SendButton
@onready var clear_button: Button = $MarginContainer/VBoxContainer/BottomBar/ClearButton

var api: AIApi


func _ready() -> void:
	title.text = "AI Assistant"

	api = AIApi.new()
	add_child(api)

	api.response_received.connect(_on_ai_response)
	api.request_failed.connect(_on_ai_error)

	send_button.pressed.connect(_on_send_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)
	prompt.text_submitted.connect(_on_prompt_submitted)


func _on_prompt_submitted(_text: String) -> void:
	_on_send_pressed()


func _on_send_pressed() -> void:
	var message := prompt.text.strip_edges()

	if message.is_empty():
		chat_history.text += "Please enter a message before sending.\n"
		return

	chat_history.text += "[You] " + message + "\n"

	send_button.disabled = true
	prompt.clear()

	api.send_message(message)


func _on_ai_response(text: String) -> void:
	chat_history.text += "[AI] " + text + "\n"
	send_button.disabled = false


func _on_ai_error(error: String) -> void:
	chat_history.text += "[Error] " + error + "\n"
	send_button.disabled = false


func _on_clear_button_pressed() -> void:
	chat_history.clear()
	prompt.clear()
