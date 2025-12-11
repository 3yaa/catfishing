class_name ColorBlindManager
extends ColorRect

var shader_material: ShaderMaterial


func _ready():
	color = Color(1, 1, 1, 0)
	shader_material = material as ShaderMaterial
	
	var mode = SettingsManager.get_colorblind_mode()
	shader_material.set_shader_parameter("mode", mode)

	
