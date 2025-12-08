extends Node2D

signal tutorial_end

signal e_pressed
signal jump_pressed
signal left_pressed
signal right_pressed
signal f_pressed
signal mini_end

@onready var game = get_node("/root/Game/WorldUI")
@onready var player = get_node("/root/Game/Player")
@onready var camera = get_node("/root/Game/Camera2D")
@onready var clock = get_node("/root/Game/Clock")
@onready var npc1 = get_node("/root/Game/Npc1")
@onready var npc2 = get_node("/root/Game/Npc2")
@onready var upgrade = get_node("/root/Game/UpgradeShop")
@onready var shop = get_node("/root/Game/FishShop")
@onready var fish = get_node("/root/Game/FishLogic")
@onready var minigame = get_node("/root/Game/MinigameContainer/Minigame/MinigameManager")

@onready var text_manager = get_node("/root/Game/Player/Text_Manager")
@onready var label = get_node("/root/Game/Player/Text_Manager/Tutorial")
@onready var mini_label = get_node("/root/Game/MinigameContainer/Minigame/MinigameUI/Rules")

var temporary_binding = false
var tutorial_ongoing = true
var won_minigame:bool

func _ready():
	label.visible = true
	label.add_theme_color_override("font_color", Color.BLACK)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2(800, 800)
	label.add_theme_color_override("default_color", Color(0.0, 0.0, 0.0, 1.0))
	game.tutorial_start.connect(_on_tutorial_start) 
	minigame.caught_fish.connect(_caught_fish)
	minigame.lost_fish.connect(_lost_fish)
	
		
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
	# allow for gravity for 2~ seconds
	game.allow_input = true
	#await get_tree().create_timer(1.0).timeout
	temporary_binding = true
	# Start tutorial:
	_movement_guide()

func _movement_guide():
	# temporarily prevent player movement
	# game.allow_input = false
	#label.text = "Welcome to the tutorial! Press 'e' to continue tutorial!"
	#await self.e_pressed
	#label.text = "Movement is based on standard WASD and space controls"
	#await self.e_pressed
#
	#game.allow_input = true
	#label.text = "Trying moving right, press 'D'!"
	#await self.right_pressed
	#label.text = "Awesome!"
	#await get_tree().create_timer(0.8).timeout
	#game.allow_input = false
	#player.animated_sprite.play("idle")
	#await self.e_pressed
	#
	#label.text = "Trying moving left, press 'A'!"
	#game.allow_input = true
	#await self.left_pressed
	#label.text = "Great!"
	#await get_tree().create_timer(0.8).timeout
	#game.allow_input = false
	#player.animated_sprite.play("idle")
	#await self.e_pressed
	#
	#label.text = "Finally, try jumping, press 'W' or 'SPACE'!"
	#game.allow_input = true
	#await self.jump_pressed
	#label.text = "Amazing! Let's move onto fishing then!"
	#await get_tree().create_timer(0.8).timeout
	#game.allow_input = false
	#player.animated_sprite.play("idle")
	#await self.e_pressed
	#game.allow_input = true
	text_manager.textbox_node.visible = true
	label.text = "Welcome to Catfishing! Press 'e' to continue!"
	await self.e_pressed
	label.text = "'e' will be the 'interact' button used to exhaust dialogue and talk to npcs!"
	await self.e_pressed
	label.text = "The movement controls are basic WASD and SPACE binding"
	await self.e_pressed
	_rescue_guide()
	

func _rescue_guide():
	print("Rescue guide")
	label.text = "Try going to the ocean to get into your boat!"
	while not player.is_in_ocean:
		await get_tree().create_timer(0.5).timeout
	label.text = "You're doing great!"
	await self.e_pressed
	game.allow_input = false
	label.text = "Oh no! Someone is drowning over there!"
	await self.e_pressed
	label.text = "Quick, go to that cat! Press e to save the cat!"
	game.allow_input = true
	while not npc1.rescued:
		await get_tree().create_timer(0.5).timeout
	game.allow_input = false
	label.text = "Thank you for saving me! I'm feline great"
	await self.e_pressed
	#label.text = "Can you save my friend too, they're deeper in!"
	#await self.e_pressed
	#game.allow_input = true
	#label.text = "Quick, save the other cat too!"
	#while not npc2.rescued:
		#await get_tree().create_timer(0.5).timeout
	#game.allow_input = false
	#label.text = "Thanks for saving me! You're ameowzing."
	#await self.e_pressed
	#label.text = "You're a good man, Jack Meowgan."
	#await self.e_pressed
	label.text = "We got a little sidetracked, let's try fishing!"
	await self.e_pressed
	_fishing_guide()

# might have to add a tutorial for rescuing? :sob: :wilted:
# ensure player does not go back to ocean by setting a boundary idk?
func _fishing_guide():
	print("fishing start")
	label.text = "Press 'F' once to cast your reel!"
	await self.f_pressed
	label.text = "Now we wait for a bite, don't move or it will scare the fish!"
	await get_tree().create_timer(3.0).timeout
	label.text = "Oh, Looks like you got a bite!"
	await self.e_pressed
	_minigame_guide()
	
	
func _minigame_guide():
	print("minigame start")
	# static fish for tutorial purposes:
	fish.current_fish = fish.Fish.new(10.0, 0, 100.0)
	label.text = "Give it a try, beat the fish!"
	await self.e_pressed
	mini_label.visible = true
	player.fish_reeled.emit()
	await self.mini_end
	mini_label.visible = false
	match won_minigame:
		true:
			label.text = "Great, you caught your first fish!"
		false:
			label.text = "Better luck next time!"
	await self.e_pressed
	# probably manually add a pre-determined fish to sell later
	_day_night_cycle_guide()
	
func _caught_fish():
	won_minigame = true
	mini_end.emit()
	
func _lost_fish():
	won_minigame = false
	mini_end.emit()	
	
	
func _day_night_cycle_guide():
	print("cycle start")
	# clock.cycle_changed.emit(not clock.is_day)
	clock.is_day = false
	label.text = "Looks like it's gotten late, we should return back"
	await self.e_pressed
	label.text = "We have to return back to the island at night, it's dangerous"
	await self.e_pressed
	label.text = "You will be rescued if you stay out too long and you might lose some fish you caught!"
	game.allow_input = true
	while player.is_in_ocean:
		await get_tree().create_timer(0.5).timeout
	label.text = "You're back on the island!"
	await self.e_pressed
	_sell_fish_guide()
	
func _sell_fish_guide():
	print("sell start")
	label.text = "Thanks for saving me earlier, you can sell me your fish!"
	await self.e_pressed
	label.text = "You can sell your fish here for money"
	await self.e_pressed
	label.text = "Money has various uses, keep playing to find out!"
	await self.e_pressed
	#await shop.shop_open
	#label.text = "Press sell to sell your fish here, press the X to exit"
	#await shop.shop_close
	# sell fish and whatnot
	# _skills_guide()
	_on_tutorial_end()
	
func _skills_guide():
	print("skill start")
	label.text = "You saved me earlier, I can upgrade your skills!"
	await self.e_pressed
	label.text = "There are three stats: PLACEHOLDER"
	await self.e_pressed
	label.text = "Try upgrading a skill!"
	await upgrade.shop_open
	label.text = "Choose an upgrade, then press X to exit"
	await upgrade.shop_close
	_on_tutorial_end()
	
func _on_tutorial_end():
	label.text = "That's it for the tutorial, go catch some fish!"
	await self.e_pressed
	label.visible = false
	temporary_binding = false
	clock.cycle_changed.emit(not clock.is_day)
	clock.is_day = true
	tutorial_ongoing = false
	text_manager.textbox_node.visible = false
	emit_signal("tutorial_end")
