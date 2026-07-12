@tool
extends EditorPlugin

const DOCK_SCENE := preload("res://addons/ai-assistant/dock.tscn")

var dock: Control


func _enter_tree() -> void:
	print("AI Assistant Loaded")

	dock = DOCK_SCENE.instantiate()
	add_control_to_bottom_panel(dock, "AI Assistant")


func _exit_tree() -> void:
	if is_instance_valid(dock):
		remove_control_from_bottom_panel(dock)
		dock.queue_free()
		dock = null
