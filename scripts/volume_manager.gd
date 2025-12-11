extends HSlider


func _ready() -> void:
	var volume = SettingsManager.get_volume()
	value = volume
	change_volume(volume)
	
	value_changed.connect(change_volume)


func change_volume(volume: float):
	SettingsManager.set_volume(volume)
	var bus = AudioServer.get_bus_index("Master")
	
	if volume == 0:
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)
		AudioServer.set_bus_volume_linear(bus, volume)
		
