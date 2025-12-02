class_name FishLogic
extends Node2D

@onready var player = get_node("/root/Game/Player")
var any_fish = false

# size params
var size_min:float = 1.0
var size_max:float = 20.0


var current_fish:Fish = null
enum Rarity {
	COMMON,
	RARE,
	SUPER_RARE
}

var fishing_cooldown = 0.5
var fishing_timer = 0.0
	
class Fish:
	var size:float
	var fish_rarity: Rarity
	var value:float 
	
	func _init(new_size:float, new_rarity:int, new_value:float):
		self.size = new_size
		self.fish_rarity = new_rarity
		self.value = new_value
		
	# function for verbose output, doesnt functionally do anything
	func stringify() -> String:
		var rarity_names = ["COMMON", "RARE", "SUPER_RARE"]
		var rarity_name = rarity_names[fish_rarity]
		return "Fish(size=%s, rarity=%s, value=%s)" % [size, rarity_name, value]

func _process(_delta):
	if player.is_fishing:
		fishing_timer -= _delta
		if fishing_timer <= 0:
			fishing_timer = fishing_cooldown
			if not any_fish:
				current_fish = make_fish()
				any_fish = true
			# when we implement player stats:
			else:
				var roll = randf() * 100
				print(roll)
				print(player.reel_skill)
				if player.reel_skill > roll:
					# probably do some probability algorithm where reeling chance is calculated
					# use that reeling chance and if it lands, send the fish caught signal
					player.fish_caught.emit()
					print(current_fish.stringify())
					player.is_fishing = false
					any_fish = false
	
	
func make_fish() -> Fish:
	var size:float = randf_range(size_min, size_max)
	var rarity:int = random_rarity()
	# value is calculated by the size, then multiplied by two scalers:
	# player.salesman: small bonus to get more money
	# rarity: scalar between 1-3x, biggest boost of value to fish
	var value:float = player.salesman * size * (rarity + 1)
	# this trunctuates the float to 2 decimal places
	value = floor(value * 100) / 100.0
	var new_fish = Fish.new(size, rarity, value)
	return new_fish
	
func random_rarity() -> int:
	# get a prelimiary roll of 1-100
	var roll = randi() % 100 + 1
	
	# basic luck distribution is:
	# SUPER_RARE(2): player.luck %
	# RARE(1): 2 * player.luck %
	# COMMON(0): [100 - (3 * player.luck) ]%
	if roll < player.luck:
		return 2 # super rare fish!
	elif roll < player.luck * 3:
		return 1 # super rare 
	else:
		return 0 # common fish

	
