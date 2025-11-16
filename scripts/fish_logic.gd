class_name FishLogic
extends Node2D

@onready var player = get_node("/root/Game/Player")
var any_fish = false

# size params
var size_min:float = 0.1
var size_max:float = 5.0
# rarity params
var rarity_min:float = 0.1
var rarity_max:float = 5.0
# value params
# might dynamically calculate value based on rarity and size later on
var value_min:float = 0.1
var value_max:float = 5.0

var current_fish:Fish = null

class Fish:
	var size:float
	var rarity:float #  change to enum later probably
	var value:float 
	
	func _init(new_size: float, new_rarity:float, new_value:float):
		self.size = new_size
		self.rarity = new_rarity
		self.value = new_value
		

func _process(_delta):
	if player.is_fishing:
		if not any_fish:
			current_fish = make_fish()
		# when we implement player stats:
		# probably do some probability algorithm where reeling chance is calculated
		# use that reeling chance and if it lands, send the fish caught signal
		player.fish_caught.emit()
		player.is_fishing = false
	else:
		pass
	
func make_fish() -> Fish:
	var new_fish = Fish.new(
		randf_range(size_min, size_max), 
		randf_range(rarity_min, rarity_max), 
		randf_range(value_min, value_max))
	return new_fish
	
