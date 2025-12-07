extends CanvasLayer
@onready var day_bg = $DayBackground
@onready var night_bg = $NightBackground
@onready var player = $Player
@onready var sprite = $Player/AnimatedSprite2D

var screen_width = 1920
var walk_duration = 20.0 # seconds to cross screen
# 
var transition_time = 2.0 # seconds for fade
var hold_time = 10.0 # seconds to hold each image
var timer = 0.0
var is_day = true

func _ready():
	night_bg.modulate.a = 0.0 # start wiht day
	# 
	player.position.x = 0
	player.position.y = 1200
	sprite.play("idle_ocean")
	start_walking()

func start_walking():
	walk_right()

func _process(delta):
	timer += delta
	
	# hold current image
	if timer < hold_time:
		return
	
	# transition phase
	var transition_progress = (timer - hold_time) / transition_time
	
	if transition_progress >= 1.0:
		# transition complete -> switch and reset
		is_day = !is_day
		timer = 0.0
		
		if is_day:
			night_bg.modulate.a = 0.0
		else:
			night_bg.modulate.a = 1.0
	else:
		if is_day:
			# fade to night
			night_bg.modulate.a = transition_progress
		else:
			# fade to day
			night_bg.modulate.a = 1.0 - transition_progress

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_exit_button_pressed():
	get_tree().quit()

# player
func walk_right():
	sprite.flip_h = false
	var tween = create_tween()
	tween.tween_property(player, "position:x", screen_width, walk_duration)
	tween.tween_callback(walk_left)

func walk_left():
	sprite.flip_h = true
	var tween = create_tween()
	tween.tween_property(player, "position:x", 0, walk_duration)
	tween.tween_callback(walk_right)
