class_name LockCamera
extends Camera2D

@export var target: CharacterBody2D

func _physics_process(_delta: float) -> void:
	if target:
		global_position = Vector2(target.global_position.x, target.global_position.y - 170)
