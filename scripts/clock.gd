class_name Clock
extends Node2D


signal cycle_changed(is_day:bool)		# Might not need

var timer: SceneTreeTimer = null

var is_day:bool = true
var day_duration:float = 30.0
var night_duration:float = 15.0


func _ready():
	is_day = true
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
	
	timer = get_tree().create_timer(duration)
	await timer.timeout
	
	is_day = !is_day
	cycle_changed.emit(is_day)
	
	_start_cycle()
	

func get_remaining_time():
	if timer:
		return timer.time_left
	else:
		return 0.0
