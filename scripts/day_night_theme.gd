class_name DayNightTheme
extends ColorRect

@onready var clock = $"../../Clock"
@export var day_color: Color = Color("#ffebb340")
@export var night_color: Color = Color("#0f0f28b3")


func _ready() -> void:
	clock.cycle_changed.connect(change_theme)
	color = day_color
	
	
func change_theme(is_day: bool):
	var theme_color = day_color if is_day else night_color
	
	var tween = create_tween()
	tween.tween_property(self, "color", theme_color, 3)
