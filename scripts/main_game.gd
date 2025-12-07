class_name MainGame
extends Node2D

@onready var minigame_container = $MinigameContainer
@onready var minigame = $MinigameContainer/Minigame
@onready var minigame_trigger_button = $WorldUI/MinigameTriggerButton

func _ready() -> void:
	# minigame initially hide
	minigame_container.visible = false
	
	# TEMP button to start minigame
	minigame_trigger_button.pressed.connect(_on_minigame_trigger_pressed)
	
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
	
	# initial game con
	# NEED TO PASS ACTUAL SCORE FISH ------------
	var fish_target_score = 500
	var player_starting_score = 100 # UPDATE STARTING PALYER SCORE
	
	minigame.get_node("MinigameManager").initialize_minigame(fish_target_score, player_starting_score)
	minigame.get_node("MinigameManager").new_game()
	minigame._start_minigame()

func _on_minigame_complete() -> void:
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
