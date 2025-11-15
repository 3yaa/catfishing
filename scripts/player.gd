class_name Player
extends CharacterBody2D

const SPEED_LAND = 150.0
const SPEED_OCEAN = 75.0
const JUMP_VELOCITY = -250.0

var is_in_ocean = false
var speed = SPEED_LAND

signal fish_caught

@onready var animated_sprite = $AnimatedSprite2D
@onready var clock = $"../Clock"


func _ready():
	var ui = get_node("/root/Game/UI")
	fish_caught.connect(ui.caught_fish)
	
	
func _process(delta: float) -> void:
	if is_in_ocean:
		speed = SPEED_OCEAN
	else:
		speed = SPEED_LAND
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		fish_caught.emit()
		velocity.x = direction * speed
		animated_sprite.flip_h = direction < 0
		if is_in_ocean:
			animated_sprite.play("swim")
		else:
			animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if is_in_ocean:
			animated_sprite.play("idle_ocean")
		else:
			animated_sprite.play("idle")
	
	# Handle jump/fall animations
	if not is_on_floor():
		animated_sprite.play("jump")

	move_and_slide()
	
	
func enter_ocean():
	print("Enter ocean")
	is_in_ocean = true
	
	
func exit_ocean():
	print("Exit ocean")
	is_in_ocean = false
	
	
