extends CanvasLayer

@onready var fish_score = $FishCounter/FishScore

@onready var clock = $"../Clock"
@onready var ui_clock_phase = $TimeOfDay/Phase
@onready var ui_clock_time = $TimeOfDay/Time

var fish_count: int = 0

func _ready() -> void:
	await get_tree().process_frame
		
	update_fish_display()
	update_clock_display()
	

func _process(delta: float) -> void:
	update_clock_display()
	
func _add_fish() -> void:
	fish_count += 1
	update_fish_display()

func update_fish_display() -> void:
	fish_score.text = str(fish_count)

# call when caught fish
func caught_fish() -> void:
	_add_fish()
	
func update_clock_display() -> void:
	if clock.day:
		ui_clock_phase.text = "Day"
	else:
		ui_clock_phase.text = "Night"
		
	ui_clock_time.text = str(int(clock.get_remaining_time()))
		
		
	
