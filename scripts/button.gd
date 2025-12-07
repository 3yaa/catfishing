extends Button

var original_y = 0.0
var time = 0.0

func _ready():
	original_y = position.y

func _physics_process(delta):
	time += delta
	# linear up and down - no slow down at peaks
	var cycle = fmod(time * 3, PI * 2)
	var triangle = abs((cycle / PI) - 1.0) * 2.0 - 1.0
	position.y = original_y + triangle * 8
