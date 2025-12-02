extends Node2D

signal cutscene_end

func _ready():
	var game = get_node("/root/Game/WorldUI")
	game.cutscene_start.connect(_on_cutscene_start) 
	
func _on_cutscene_start():
	print("Cutscene started")
	await get_tree().create_timer(2.0).timeout
	print("Cutscene ended")
	emit_signal("cutscene_end")
