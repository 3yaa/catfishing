class_name MainGame
extends Node2D

@onready var minigame_container = $MinigameContainer
@onready var minigame = $MinigameContainer/Minigame
@onready var minigame_trigger_button = $WorldUI/MinigameTriggerButton
@onready var player = get_node("/root/Game/Player")

func _ready() -> void:
	# minigame initially hide
	minigame_container.visible = false
	
	# TEMP button to start minigame
	# minigame_trigger_button.pressed.connect(_on_minigame_trigger_pressed)
	
	# when the fish is caught, the minigame is triggered
	player.fish_reeled.connect(_on_minigame_trigger_pressed)
	
	# connect minigame finish signals
	var mg_manager = minigame.get_node("MinigameManager")
	print("Connecting to MinigameManager: ", mg_manager)
	mg_manager.caught_fish.connect(_on_minigame_complete)
	mg_manager.lost_fish.connect(_on_minigame_complete)
	print("Signals connected successfully")

func _on_minigame_trigger_pressed() -> void:
	# show minigame
	minigame_container.visible = true
	
	# pause game
	get_tree().paused = true
	
	# use player money as starting score
	var player_starting_score = int(player.money)
	
	# rarity determines how much to add to current score for target
	var fish_logic = get_node("/root/Game/FishLogic")
	var rarity_bonus = 100 # default
	
	if fish_logic.current_fish:
		match fish_logic.current_fish.fish_rarity:
			0: # COMMON
				rarity_bonus = 100
			1: # RARE
				rarity_bonus = 200
			2: # SUPER_RARE
				rarity_bonus = 450
	
	var fish_target_score = player_starting_score + rarity_bonus
	
	minigame.get_node("MinigameManager").initialize_minigame(fish_target_score, player_starting_score)
	minigame.get_node("MinigameManager").new_game()
	minigame._start_minigame()

func _on_minigame_complete() -> void:
	# update money with minigame score
	var mg_manager = minigame.get_node("MinigameManager")
	player.money = float(mg_manager.player_score)
	
	# timer processes when paused
	var timer = Timer.new()
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.wait_time = 3.0
	timer.one_shot = true
	add_child(timer)
	timer.start()
	print("Timer started, waiting 3 seconds...")
	await timer.timeout
	timer.queue_free()
	
	# close minigame
	minigame_container.visible = false
	
	# unpause the game
	get_tree().paused = false
