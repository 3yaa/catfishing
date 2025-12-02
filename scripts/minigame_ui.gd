@onready var mg_manager = $MinigameManager
@onready var hit_btn = $HitButton
@onready var stand_btn = $StandButton

func _ready():
	hit_btn.pressed.connect(_on_hit)
	stand_btn.pressed.connect(_on_stand)

func _on_hit():
	mg_manager.current_game.hit()
	if mg_manager.current_game.is_finished():
		mg_manager.finish_game()

func _on_stand():
	mg_manager.current_game.stand()
	mg_manager.finish_game()
