class_name NPCFishShop
extends NPC

const position_ocean = Vector2(920, 295)
const position_island = Vector2(500, 295)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	global_position = position_ocean


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_player and not rescued and Input.is_action_just_pressed("interact"):
		rescue()
	
	
func rescue():
	rescued = true
	global_position = position_island
