extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

signal fish_caught

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	var ui = get_node("/root/Game/UI")
	fish_caught.connect(ui.caught_fish)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		fish_caught.emit()
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")
	
	# Handle jump/fall animations
	if not is_on_floor():
		animated_sprite.play("jump")

	move_and_slide()
