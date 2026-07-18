@tool
extends Control

const AIApiScript = preload("res://addons/ai-assistant/api.gd")

@onready var title: Label = $MarginContainer/VBoxContainer/Header/Title
@onready var chat_history: RichTextLabel = $MarginContainer/VBoxContainer/Conversation
@onready var prompt: LineEdit = $MarginContainer/VBoxContainer/Prompt
@onready var send_button: Button = $MarginContainer/VBoxContainer/BottomBar/SendButton
@onready var clear_button: Button = $MarginContainer/VBoxContainer/BottomBar/ClearButton
@onready var status_label: Label = $MarginContainer/VBoxContainer/BottomBar/StatusLabel
@onready var settings_button: Button = $MarginContainer/VBoxContainer/Header/SettingsButton
@onready var settings_dialog: ConfirmationDialog = $SettingsDialog
@onready var unique_key_input: LineEdit = $SettingsDialog/VBoxContainer/UniqueKeyInput
@onready var api_url_input: LineEdit = $SettingsDialog/VBoxContainer/ApiUrlInput
@onready var settings_status: Label = $SettingsDialog/VBoxContainer/SettingsStatus

var api
var current_user_name := ""

func _ready() -> void:

	chat_history.clear()
	chat_history.append_text(
		"👋 Welcome!\nAsk any question related to Godot, GDScript, scenes, nodes, UI, physics, shaders, plugins, or editor tools.\n\n"
	)

	title.text = "AI Assistant"
	status_label.text = "Loading..."
	
	api = AIApiScript.new()
	add_child(api)
	await get_tree().process_frame

	api.response_received.connect(_on_ai_response)
	api.request_failed.connect(_on_ai_error)
	api.user_loaded.connect(_on_user_loaded)

	api.load_user()

	send_button.pressed.connect(_on_send_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)
	prompt.text_submitted.connect(_on_prompt_submitted)
	
	settings_button.pressed.connect(_on_settings_pressed)
	settings_dialog.confirmed.connect(_on_settings_saved)

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


func _on_ai_response(text: String, plan: String, credits: int) -> void:
	chat_history.text += "[AI] " + text + "\n"

	status_label.text = "%s • %s • %d Credits" % [current_user_name, plan, credits]
	
	send_button.disabled = false

func _on_user_loaded(name: String, plan: String, credits: int) -> void:
	current_user_name = name
	status_label.text = "%s • %s • %d Credits" % [name, plan, credits]
	
func _on_ai_error(error: String) -> void:
	chat_history.text += "[Error] " + error + "\n"
	send_button.disabled = false


func _on_clear_button_pressed() -> void:
	chat_history.clear()
	prompt.clear()
	
func _on_settings_pressed() -> void:
	unique_key_input.text = AISettings.load_key()
	api_url_input.text = AISettings.load_url()

	settings_status.text = ""
	settings_dialog.popup_centered()

func _on_settings_saved() -> void:
	var key := unique_key_input.text.strip_edges()
	var url := api_url_input.text.strip_edges()

	if key.is_empty():
		settings_status.text = "Please enter your API Key."
		return

	if url.is_empty():
		settings_status.text = "Please enter API URL."
		return

	AISettings.save(key, url)
	settings_status.text = "Settings saved successfully."
