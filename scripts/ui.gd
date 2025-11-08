extends CanvasLayer

@onready var fish_score = $FishCounter/FishScore

var fish_count: int = 0
var time_elapsed: float = 0.0

func _ready() -> void:
	update_fish_display()
	#update_clock_display()

func _process(delta: float) -> void:
	return
	
func _add_fish() -> void:
	fish_count += 1
	update_fish_display()

func update_fish_display() -> void:
	fish_score.text = str(fish_count)

# call when caught fish
func caught_fish() -> void:
	_add_fish()
