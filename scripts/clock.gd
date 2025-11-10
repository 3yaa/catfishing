class_name Clock
extends Node2D


signal cycle # emitted when day/night cycle should change


var time:int = 0
var day:bool = true
var daytime:float = 10.0


func _ready():
	time = 0
	day = true
	cycle.connect(_switch)
	

# idea is to call this function from the main script:
# main script should await the signal "cycle" before calling again
func _start_cycle():
	print("daytime: {}", daytime)
	print("Cycle start")
	
	await get_tree().create_timer(daytime).timeout
	
	print("Cycle end")
	emit_signal("cycle")
	
	
func _switch():
	print("Changing to day/night")
	day = !day
	# signal to change the background perhaps
