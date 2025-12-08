class_name Player
extends CharacterBody2D

const SPEED_LAND = 150.0
const SPEED_OCEAN = 75.0
const JUMP_VELOCITY = -250.0

var is_in_ocean = false
var is_fishing = false
var speed = SPEED_LAND
var spawn_position = Vector2()

var fish_escape_flag = false

# Stats?
var reel_skill: float = 10.0 # reel_skill indicates how fast the fish hooks
var luck: float = 10.0 # luck indicates how likely you are to get rarer fish
var salesman: float = 1.0 # salesman indicates how much more you can sell a fish for

var power_ups = {
	power1 = false,
	power2 = false,
	power3 = false,
}

var money: float = 100.0

signal fish_caught
signal fish_reeled
signal is_late # Triggered when stay too late in ocean and got teleport back

@onready var animated_sprite = $AnimatedSprite2D
@onready var clock = $"../Clock"
@onready var game = get_node("/root/Game/WorldUI")
@onready var tutorial = get_node("/root/Game/Tutorial_Manager")
@onready var fish = $"../FishLogic"

func _ready():
	var ui = get_node("/root/Game/WorldUI")
	fish_caught.connect(ui.caught_fish)
	
	spawn_position = global_position
	
	
func _process(delta: float) -> void:
	if is_in_ocean:
		speed = SPEED_OCEAN
		# if "fishing button" pressed:
		if (Input.is_action_just_pressed("fishing")):
			animated_sprite.play("cast")
			is_fishing = true
			print("reeled")
	else:
		speed = SPEED_LAND
		
	handle_late_in_ocean()
	

func _physics_process(delta: float) -> void:
	# make sure movement is allowed:
	# movement may not be allowed during cutscene + tutorial
	if game.allow_input:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor() and not is_in_ocean:
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		var direction := Input.get_axis("ui_left", "ui_right")
		# any movement while fishing should "cancel" the reel
		if direction != 0:
			is_fishing = false
		
		if direction:
			#fish_caught.emit()
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
				$Audio/Sailing.play()
				
			else:
				animated_sprite.play("idle")
				$Audio/Sailing.stop()
		
		# Handle jump/fall animations
		if not is_on_floor():
			animated_sprite.play("jump")

		move_and_slide()
	
	
func enter_ocean():
	print("Enter ocean")
	if not is_in_ocean:
		fish_escape_flag = false
	
	is_in_ocean = true
	$Audio/GettingInBoat.play()
	
	
func exit_ocean():
	print("Exit ocean")
	is_in_ocean = false
	

# When stay too late in ocean: pass out, get teleported back, lose some fish
func handle_late_in_ocean():
	if not tutorial.tutorial_ongoing and is_in_ocean and not clock.is_day and clock.get_remaining_time() < 5.0:
		global_position = spawn_position
		is_late.emit()
		
		if not fish_escape_flag:
			var escaped_fish: Array = []
			for i in range(fish.fish_inventory.size() - 1, 0, -1):
				if i % 2 == 1:
					escaped_fish.append(fish.fish_inventory[i])
					fish.fish_inventory.remove_at(i)
				
			fish_escape_flag = true
			
			game.display_passout(escaped_fish)
