class_name FishShopManager
extends Panel

@onready var player = $"../Player"
@onready var fish_logic = $"../FishLogic"
@onready var world_ui = $"../WorldUI"

@onready var ui_fish_count = $FishCount/Number
@onready var ui_fish_value = $Price/Number
@onready var sell_btn = $Sell
@onready var close = $Close
@onready var debt_btn = $Debt

@onready var scanner = $Scanner
@onready var input = $Scanner/Input
@onready var debt = get_node("/root/Game/WorldUI/Debt")
@onready var enter = $Scanner/Enter
@onready var invalid = $Invalid

signal shop_open
signal shop_close
signal sold
var debt_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	input.visible = false
	scanner.visible = false
	enter.visible = false
	invalid.visible = false
	invalid.add_theme_color_override("font_color", Color.RED)
	sell_btn.pressed.connect(sell)
	close.pressed.connect(disable_shop)
	debt_btn.pressed.connect(open_debt)
	enter.pressed.connect(process_debt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func open_debt():
	scanner.visible = true
	input.visible = true
	enter.visible = true
	invalid.visible = false
	scanner.position = Vector2(player.position.x, player.position.y - 800)
	input.text = ""
	
func process_debt():
	if input.text == "":
		print("Empty")
		return
	
	var number = int(input.text)
	if number > player.money:
		invalid.visible = true
	else:
		player.money -= number
		debt.update_debt(number)
		
	scanner.visible = false
	input.visible = false
	enter.visible = false
	debt_open = false

func enable_shop():
	update_shop_ui()
	emit_signal("shop_open")
	show()
	world_ui.allow_input = false
	

func disable_shop():
	emit_signal("shop_close")
	scanner.visible = false
	hide()
	world_ui.allow_input = true
	

func update_shop_ui():
	ui_fish_count.text = str(fish_logic.fish_inventory.size())
	ui_fish_value.text = "$" + str(get_total_fish_value())


func sell():
	var fish_value = get_total_fish_value()
	print("Sell for $", fish_value)
	player.money += fish_value
	fish_logic.fish_inventory.clear()
	update_shop_ui()
	
	
func get_total_fish_value():
	var value = 0
	for fish in fish_logic.fish_inventory:
		value += fish.value
	return value
