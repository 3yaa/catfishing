extends Node2D


@onready var player = get_parent()


func _process(delta):
	$Hint.position = Vector2(-$Hint.get_minimum_size().x / 2, -400)
	$Tutorial.position = Vector2(-$Tutorial.size.x / 2, -400)
