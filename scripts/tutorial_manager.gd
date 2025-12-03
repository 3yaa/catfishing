extends Node2D

signal tutorial_end

signal e_pressed
signal jump_pressed
signal left_pressed
signal right_pressed
signal f_pressed


@onready var game = get_node("/root/Game/WorldUI")
@onready var player = get_node("/root/Game/Player")
@onready var camera = get_node("/root/Game/Camera2D")
@onready var clock = get_node("/root/Game/Clock")

var temporary_binding = false
var tutorial_ongoing = true

func _ready():
	$Label.visible = true
	game.tutorial_start.connect(_on_tutorial_start) 
	
func _physics_process(_delta):
	if $Label.visible:
		# $Label.position = Vector2(player.position.x - $Label.size.x / 2, player.position.y - $Label.size.y * 8)
		$Label.position = camera.position
	
func _input(event):
	if not temporary_binding:
		return 
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_E:
				emit_signal("e_pressed")
			KEY_SPACE, KEY_W:
				emit_signal("jump_pressed")
			KEY_A:
				emit_signal("left_pressed")
			KEY_D:
				emit_signal("right_pressed")
			KEY_F:
				emit_signal("f_pressed")
	

func _on_tutorial_start():
	print("Tutorial started")
	await get_tree().create_timer(2.0).timeout
	temporary_binding = true
	# Start tutorial:
	_movement_guide()

func _movement_guide():
	# temporarily prevent player movement
	game.allow_input = false
	$Label.text = "Welcome to the tutorial! Press 'e' to continue tutorial!"
	await self.e_pressed
	$Label.text = "Movement is based on standard WASD and space controls"
	await self.e_pressed

	game.allow_input = true
	$Label.text = "Trying moving right, press 'D'!"
	await self.right_pressed
	$Label.text = "Awesome!"
	await get_tree().create_timer(0.8).timeout
	game.allow_input = false
	player.animated_sprite.play("idle")
	await self.e_pressed
	
	$Label.text = "Trying moving left, press 'A'!"
	game.allow_input = true
	await self.left_pressed
	$Label.text = "Great!"
	await get_tree().create_timer(0.8).timeout
	game.allow_input = false
	player.animated_sprite.play("idle")
	await self.e_pressed
	
	$Label.text = "Finally, try jumping, press 'W' or 'SPACE'!"
	game.allow_input = true
	await self.jump_pressed
	$Label.text = "Amazing! Let's move onto fishing then!"
	await get_tree().create_timer(0.8).timeout
	game.allow_input = false
	player.animated_sprite.play("idle")
	await self.e_pressed
	game.allow_input = true
	
	_fishing_guide()
	
# might have to add a tutorial for rescuing? :sob: :wilted:
# ensure player does not go back to ocean by setting a boundary idk?
func _fishing_guide():
	print("fishing start")
	$Label.text = "Now, try going to the ocean to get into your boat!"
	while not player.is_in_ocean:
		await get_tree().create_timer(0.5).timeout
	$Label.text = "Great Job! Now Let's Try Fishing!"
	await self.e_pressed
	game.allow_input = false
	$Label.text = "Press 'F' to cast your reel!"
	await self.f_pressed
	$Label.text = "Now we wait for a bite, it usually takes a bit"
	await get_tree().create_timer(3.0).timeout
	$Label.text = "Oh, Looks like you got a bite!"
	await self.e_pressed
	_minigame_guide()
	
func _minigame_guide():
	print("minigame start")
	# basically load up the minigame
	$Label.text = "Great, you caught your first fish!"
	await self.e_pressed
	# probably manually add a pre-determined fish to sell later
	_day_night_cycle_guide()
	
func _day_night_cycle_guide():
	print("cycle start")
	clock.cycle_changed.emit(not clock.is_day)
	clock.is_day = false
	$Label.text = "Looks like it's gotten late, we should return back"
	await self.e_pressed
	$Label.text = "We have to return back to the island at night, it's dangerous"
	await self.e_pressed
	$Label.text = "If you stay out too long, you will be transported back to the island automatically"
	game.allow_input = true
	while player.is_in_ocean:
		await get_tree().create_timer(0.5).timeout
	$Label.text = "You're back on the island, you should sell your fish!"
	await self.e_pressed
	_sell_fish_guide()
	
func _sell_fish_guide():
	print("sell start")
	$Label.text = "Talk to that cat to sell your fish!"
	await self.e_pressed
	# sell fish and whatnot
	_skills_guide()
	
func _skills_guide():
	print("skill start")
	$Label.text = "You have some money, try upgrading your stats!"
	await self.e_pressed
	_on_tutorial_end()
	
func _on_tutorial_end():
	$Label.text = "That's it for the tutorial, go catch some fish!"
	await self.e_pressed
	$Label.visible = false
	temporary_binding = false
	tutorial_ongoing = false
	emit_signal("tutorial_end")
