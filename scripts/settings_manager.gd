# Autoload script
extends Node

const SETTINGS_FILE = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	var err = config.load(SETTINGS_FILE)
	if err != OK:
		pass


func get_colorblind_mode():
	return config.get_value("accessibility", "colorblind_mode", 0)
	

func set_colorblind_mode(mode: int):
	config.set_value("accessibility", "colorblind_mode", mode)
	config.save(SETTINGS_FILE)
	

func get_volume():
	return config.get_value("audio", "volume", 5)
	
	
func set_volume(volume: float):
	config.set_value("audio", "volume", volume)
	config.save(SETTINGS_FILE)
