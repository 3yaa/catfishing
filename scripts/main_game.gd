class_name MainGame
extends Node2D

@onready var minigame_container = $MinigameContainer
@onready var minigame = $MinigameContainer/Minigame
@onready var minigame_trigger_button = $WorldUI/MinigameTriggerButton
@onready var player = get_node("/root/Game/Player")
@onready var clock = $Clock

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
	clock.pause_clock()
	
	# starting score based on fish rarity
	var fish_logic = get_node("/root/Game/FishLogic")
	var player_starting_score = 50 # default for common
	var rarity_bonus = 100 # default
	
	if fish_logic.current_fish:
		match fish_logic.current_fish.fish_rarity:
			0: # COMMON
				player_starting_score = 50
				rarity_bonus = 100
			1: # RARE
				player_starting_score = 60
				rarity_bonus = 200
			2: # SUPER_RARE
				player_starting_score = 70
				rarity_bonus = 450
	
	var fish_target_score = player_starting_score + rarity_bonus
	
	minigame.get_node("MinigameManager").initialize_minigame(fish_target_score, player_starting_score)
	minigame.get_node("MinigameManager").new_game()
	minigame._start_minigame()

func _on_minigame_complete() -> void:
	# minigame no longer affects player money
	# minigame controller already handles the click-to-continue
	
	# close minigame
	minigame_container.visible = false
	
	# unpause the game
	get_tree().paused = false
	clock.resume_clock()
