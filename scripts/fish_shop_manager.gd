class_name FishShopManager
extends Panel

@onready var player = $"../Player"
@onready var fish_logic = $"../FishLogic"
@onready var world_ui = $"../WorldUI"

@onready var ui_fish_count = $FishCount
@onready var sell_btn = $Sell
@onready var close = $Close

signal shop_open
signal shop_close

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	sell_btn.pressed.connect(sell)
	close.pressed.connect(disable_shop)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func enable_shop():
	update_shop_ui()
	emit_signal("shop_open")
	show()
	world_ui.allow_input = false
	

func disable_shop():
	emit_signal("shop_close")
	hide()
	world_ui.allow_input = true
	

func update_shop_ui():
	ui_fish_count.text = str(fish_logic.fish_inventory.size())


func sell():
	var money_earned = 0
	for fish in fish_logic.fish_inventory:
		money_earned += fish.value
	print("Sell for $", money_earned)
	
	player.money += money_earned
	fish_logic.fish_inventory.clear()
	update_shop_ui()
