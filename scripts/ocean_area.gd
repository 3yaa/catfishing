extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Player):
	body.enter_ocean()
	
	
func _on_body_exited(body: Player):
	body.exit_ocean()
