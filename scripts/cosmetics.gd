extends Node2D


func _ready() -> void:
	# Turn off visibility of all cosmetics when game starts. 
	for item in get_children():
		item.visible = false
