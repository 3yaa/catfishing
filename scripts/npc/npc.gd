class_name NPC
extends Area2D

@onready var ui = $"../UI"

var rescued = false
var has_player = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	pass
	
	
func _on_body_entered(body: Player):
	if not rescued:
		ui.update_dialogue_display("Press E to rescue")
	else:
		ui.update_dialogue_display(get_interact_prompt())
	has_player = true
	
	
func _on_body_exited(body: Player):
	ui.update_dialogue_display("")
	has_player = false
	
	
func get_interact_prompt():
	return "Press E to interact"
