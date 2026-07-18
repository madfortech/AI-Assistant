extends RefCounted
class_name AISettings

const FILE := "user://ai_assistant.cfg"

const DEFAULT_API_URL := "https://aiassistant.test/api"

static func save(api_key: String, api_url: String) -> void:
	var config := ConfigFile.new()

	config.set_value("auth", "api_key", api_key)
	config.set_value("server", "url", api_url)

	config.save(FILE)


static func load_key() -> String:
	var config := ConfigFile.new()

	if config.load(FILE) != OK:
		return ""

	return config.get_value("auth", "api_key", "")


static func load_url() -> String:
	var config := ConfigFile.new()

	if config.load(FILE) != OK:
		return DEFAULT_API_URL

	return config.get_value("server", "url", DEFAULT_API_URL)
