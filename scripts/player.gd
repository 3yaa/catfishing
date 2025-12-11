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

var money: float = 50000.0

signal fish_caught
signal fish_reeled
signal is_late # Triggered when stay too late in ocean and got teleport back

@onready var animated_sprite = $AnimatedSprite2D
@onready var clock = $"../Clock"
@onready var game = get_node("/root/Game/WorldUI")
@onready var tutorial = get_node("/root/Game/Tutorial_Manager")
@onready var fish = $"../FishLogic"

# Store the base scale for animations
var base_scale: Vector2
# Fishing animation variables
var fishing_time: float = 0.0
var base_fishing_position: Vector2

func _ready():
	var ui = get_node("/root/Game/WorldUI")
	fish_caught.connect(ui.caught_fish)
	
	# store base scale
	base_scale = animated_sprite.scale
	
	# connect animation finished signal to transition from cast to fishing
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	spawn_position = global_position
	
	
func _process(delta: float) -> void:
	if is_in_ocean:
		speed = SPEED_OCEAN
		# if "fishing button" pressed:
		if (Input.is_action_just_pressed("fishing")):
			animated_sprite.play("cast")
			# scale up cast animation 
			animated_sprite.scale = base_scale * 2.8
			$Audio/Cast.play()
			is_fishing = true
			print("casting")
	else:
		speed = SPEED_LAND
	
	# 'animate' fishing sprite rocking
	if is_fishing and animated_sprite.animation == "fishing":
		fishing_time += delta
		_animate_fishing_rock()
		
	handle_late_in_ocean()

func _on_animation_finished():
	# when cast animation finishes, transition to fishing animation
	if is_fishing and animated_sprite.animation == "cast":
		animated_sprite.play("fishing")
		# scale down fishing animation by 5%
		animated_sprite.scale = base_scale * 0.75
		# store base position for rocking animation
		base_fishing_position = animated_sprite.position
		fishing_time = 0.0
		print("now fishing")

func _animate_fishing_rock():
	# Create gentle rocking motion
	var rock_y = sin(fishing_time * 1.5) * 3.0 # ver bobbing
	var rock_x = cos(fishing_time * 0.8) * 2.0 # hor sway
	var rock_rotation = sin(fishing_time * 1.2) * 0.03 # rotation
	
	animated_sprite.position = base_fishing_position + Vector2(rock_x, rock_y)
	animated_sprite.rotation = rock_rotation

func _cancel_fishing():
	# reset fishing state and progress
	is_fishing = false
	fish.any_fish = false
	fish.reel_chance = reel_skill
	# reset sprite scale and position to normal
	animated_sprite.scale = base_scale
	animated_sprite.position = Vector2(0, 2.000001)
	animated_sprite.rotation = 0.0
	fishing_time = 0.0
	print("fishing cancelled")
	

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
		if direction != 0 and is_fishing:
			_cancel_fishing()
		
		if direction:
			#fish_caught.emit()
			velocity.x = direction * speed
			animated_sprite.flip_h = direction < 0
			if is_in_ocean:
				$Audio/Walking.stop()
				animated_sprite.play("swim")
			else:
				animated_sprite.play("run")
				$Audio/Walking.stream.loop_begin = 1
				$Audio/Walking.stream.loop_end = 2
				if not $Audio/Walking.playing:
					$Audio/Walking.play()
			
		
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			if is_in_ocean:
				$Audio/Walking.stop()
				# Don't override fishing animation
				if not is_fishing:
					animated_sprite.play("idle_ocean")
				$Audio/Sailing.play()
				
			else:
				$Audio/Walking.stop()
				animated_sprite.play("idle")
				$Audio/Sailing.stop()
		
		# Handle jump/fall animations
		if not is_on_floor():
			$Audio/Jump.play()
			animated_sprite.play("jump")
			

		move_and_slide()
	
	
func enter_ocean():
	print("Enter ocean")
	if not is_in_ocean:
		fish_escape_flag = false
	
	is_in_ocean = true
	$Audio/GettingInBoat.play()
	# scale is reset
	if not is_fishing:
		animated_sprite.scale = base_scale
		animated_sprite.position = Vector2(0, 2.000001)
		animated_sprite.rotation = 0.0
	
	
func exit_ocean():
	print("Exit ocean")
	is_in_ocean = false
	# cancel fishing when exiting ocean to reset scale
	if is_fishing:
		_cancel_fishing()
	

# When stay too late in ocean (halfway through the night): pass out, get teleported back, lose some fish
func handle_late_in_ocean():
	if not tutorial.tutorial_ongoing and is_in_ocean and not clock.is_day and clock.get_remaining_time() < 0.5 * clock.night_duration:
		global_position = spawn_position
		# cancel fishing when teleported back
		if is_fishing:
			_cancel_fishing()
		is_late.emit()
		
		# Losing half the fish
		if not fish_escape_flag:
			var escaped_fish: Array = []
			for i in range(fish.fish_inventory.size() - 1, 0, -1):
				if i % 2 == 1:
					escaped_fish.append(fish.fish_inventory[i])
					fish.fish_inventory.remove_at(i)
				
			fish_escape_flag = true
			
			game.display_passout(escaped_fish)
