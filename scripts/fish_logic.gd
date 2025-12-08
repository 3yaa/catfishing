class_name FishLogic
extends Node2D

@onready var player = get_node("/root/Game/Player")
@onready var tutorial = get_node("/root/Game/Tutorial_Manager")
var any_fish = false

# size params
var size_min: float = 1.0
var size_max: float = 20.0

# base fish price, limit to 2 decimal points
var base_price: float = 10.00

var reel_chance: float

var fish_inventory: Array[Fish] = []

var current_fish: Fish = null
enum Rarity {
	COMMON,
	RARE,
	SUPER_RARE
}

var fishing_cooldown = 0.5
var fishing_timer = 0.0
	
class Fish:
	var size: float
	var fish_rarity: Rarity
	var value: float
	
	func _init(new_size: float, new_rarity: int, new_value: float):
		self.size = new_size
		self.fish_rarity = new_rarity
		self.value = new_value
		
	# function for verbose output, doesnt functionally do anything
	func stringify() -> String:
		var rarity_names = ["COMMON", "RARE", "SUPER_RARE"]
		var rarity_name = rarity_names[fish_rarity]
		return "Fish(size=%s, rarity=%s, value=%s)" % [size, rarity_name, value]
		
		
func _ready():
	# connect to minigame manager's caught_fish signal
	var mg_manager = get_node("/root/Game/MinigameContainer/Minigame/MinigameManager")
	if mg_manager:
		mg_manager.caught_fish.connect(_on_minigame_won)
		print("Connected to minigame caught_fish signal")

func _process(_delta):
	if player.is_fishing and not tutorial.tutorial_ongoing:
		fishing_timer -= _delta
		if fishing_timer <= 0:
			fishing_timer = fishing_cooldown
			if not any_fish:
				current_fish = make_fish()
				any_fish = true
				# reset the reel_chance
				reel_chance = player.reel_skill
			# when we implement player stats:
			else:
				var roll = randf() * 100
				print(roll)
				print(reel_chance)
				if reel_chance > roll:
					# trigger minigame
					player.fish_reeled.emit()
					print("Fish hooked: ", current_fish.stringify())
					player.is_fishing = false
					any_fish = false
				else:
					reel_chance += 10.0

func _on_minigame_won():
	# only add fish to inventory when minigame is won
	if current_fish:
		add_fish_to_inventory(current_fish)
		print("Fish caught and added to inventory!")
		current_fish = null

func add_fish_to_inventory(fish: Fish):
	fish_inventory.append(fish)
	print("fish added, total fish: ", fish_inventory.size())

func get_fish_count_by_rarity(rarity: int) -> int:
	var count = 0
	for fish in fish_inventory:
		if fish.fish_rarity == rarity:
			count += 1
	return count

func get_total_fish_count() -> int:
	return fish_inventory.size()
	
	
func make_fish() -> Fish:
	var size: float = randf_range(size_min, size_max)
	var rarity: int = random_rarity()
	# value is calculated by the size, then multiplied by two scalers:
	# player.salesman: small bonus to get more money
	# rarity: scalar between 1-3x, biggest boost of value to fish
	var value: float = (base_price + size) * player.salesman * (rarity + 1)
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
