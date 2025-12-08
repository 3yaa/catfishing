class_name DayNightTheme
extends ColorRect

@onready var clock = $"../../Clock"
@export var day_color: Color = Color("#ffebb340")
@export var night_color: Color = Color("#0f0f28b3")

@onready var background = get_node("/root/Game/ParallaxBackground/ParallaxLayer/Sprite2D")
@export var background_day = Texture2D
@export var background_night = Texture2D


func _ready() -> void:
	clock.cycle_changed.connect(change_theme)
	clock.cycle_changed.connect(change_background)
	color = day_color
	
	
func change_theme(is_day: bool):
	var theme_color = day_color if is_day else night_color
	
	var tween = create_tween()
	tween.tween_property(self, "color", theme_color, 3)
	

func change_background(is_day: bool):
	var new_background = background_day if is_day else background_night
	
	var tween = create_tween()
	tween.tween_property(background, "modulate", Color(0, 0, 0, 1), 3)
	tween.tween_callback(func(): background.texture = new_background)
	tween.tween_property(background, "modulate", Color(1, 1, 1, 1), 3)
