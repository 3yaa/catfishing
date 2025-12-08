class_name Clock
extends Node2D

signal cycle_changed(is_day:bool)

var timer: Timer

var is_day:bool = true
var day_duration:float = 180.0
var night_duration:float = 90.0

var is_paused = false
var paused_at: float

@onready var world = get_node("/root/Game/WorldUI")
@onready var tutorial = get_node("/root/Game/Tutorial_Manager")

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(switch_cycle)
	
	is_day = true
	if not world.dev_mode:
		await tutorial.tutorial_end
		_start_cycle()
	else:
		_start_cycle()
	

# idea is to call this function from the main script:
# main script should await the signal "cycle" before calling again
func _start_cycle():
	var duration: float
	if is_day:
		duration = day_duration
		print("Day cycle: ", duration, " s")
	else:
		duration = night_duration
		print("Night cycle: ", duration, " s")
	
	timer.start(duration)
	

func switch_cycle():
	is_day = !is_day
	cycle_changed.emit(is_day)
	_start_cycle()
	

func get_remaining_time():
	if is_paused:
		return paused_at
	elif not timer.is_stopped():
		return timer.time_left
	else:
		return 0.0
		

func pause_clock():
	if timer and not is_paused:
		is_paused = true
		paused_at = timer.time_left
		timer.stop()
	

func resume_clock():
	if is_paused:
		is_paused = false
		timer.start(paused_at)
