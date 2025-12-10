class_name NPCFishShop
extends NPC

@onready var shop = $"../FishShop"
@onready var background = $"Sprite2D"

@export var background_sprite = Texture2D

const position_ocean = Vector2(1200, 1070)
const position_island = Vector2(700, 1050)


func _ready() -> void:
	super._ready()
	global_position = position_ocean


func _process(delta: float) -> void:
	# Player interaction - E key
	if has_player and not rescued and Input.is_action_just_pressed("interact"):
		rescue()
	elif has_player and rescued and Input.is_action_just_pressed("interact"):
		shop.enable_shop()
		ui.update_dialogue_display("")
	
	
func rescue():
	rescued = true
	global_position = position_island
	background.texture = background_sprite
	background.visible = true
	play_sprite_animation()
	

# Overwrite parent dialogue
func get_interact_prompt():
	return "Press E to sell fish"
