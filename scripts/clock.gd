class_name Clock
extends Node2D


signal cycle # emitted when day/night cycle should change

var timer: SceneTreeTimer = null

var day:bool = true
var daytime:float = 30.0


func _ready():
	day = true
	cycle.connect(_switch)
	_start_cycle()
	

# idea is to call this function from the main script:
# main script should await the signal "cycle" before calling again
func _start_cycle():
	print("daytime: ", daytime)
	print("Cycle start")
	
	timer = get_tree().create_timer(daytime)
	await timer.timeout
	
	print("Cycle end")
	emit_signal("cycle")
	
	_start_cycle()
	
	
func _switch():
	print("Changing to day/night")
	day = !day
	

func get_remaining_time():
	if timer:
		return timer.time_left
	else:
		return 0.0
