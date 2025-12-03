class_name NPCFishShop
extends NPC

@onready var shop = $"../FishShop"

const position_ocean = Vector2(920, 295)
const position_island = Vector2(500, 295)


func _ready() -> void:
	super._ready()
	global_position = position_ocean


func _process(delta: float) -> void:
	if has_player and not rescued and Input.is_action_just_pressed("interact"):
		rescue()
	elif has_player and rescued and Input.is_action_just_pressed("interact"):
		shop.enable_shop()
	
	
func rescue():
	rescued = true
	global_position = position_island
	

# Overwrite prompt
func get_interact_prompt():
	return "Press E to sell fish"
