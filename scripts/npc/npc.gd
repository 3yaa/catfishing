class_name NPC
extends Area2D

@onready var ui = $"../UI"

var rescued = false
var has_player = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_body_entered(body: Player):
	if not rescued:
		ui.update_dialogue_display("Press E to rescue")
	else:
		ui.update_dialogue_display("Press E to sell fish")
	has_player = true
	
	
func _on_body_exited(body: Player):
	ui.update_dialogue_display("")
	has_player = false
