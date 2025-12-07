class_name CosmeticsShopManager
extends Panel

@onready var player = $"../Player"
@onready var world_ui = $"../WorldUI"
@onready var cosmetics = $"../Cosmetics"

@onready var house_buy =$ScrollContainer/VBoxContainer/House/Buy
@onready var cat_tree_buy = $ScrollContainer/VBoxContainer/CatTree/Buy
@onready var chair_buy = $ScrollContainer/VBoxContainer/Chair/Buy

@onready var close_btn = $Close

signal shop_open
signal shop_close

var prices = {
	"House": 50,
	"CatTree": 20,
	"Chair": 20,
}

var owned_items = {
	"House": false,
	"CatTree": false,
	"Chair": false,
}

func _ready() -> void:
	hide()
	close_btn.pressed.connect(disable_shop)
	house_buy.pressed.connect(buy_cosmetic.bind("House"))
	cat_tree_buy.pressed.connect(buy_cosmetic.bind("CatTree"))
	chair_buy.pressed.connect(buy_cosmetic.bind("Chair"))
	

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
	if owned_items["House"]:
		house_buy.text = "Owned"
		house_buy.disabled = true
	else:
		house_buy.text = "$" + str(prices["House"])
		
	if owned_items["CatTree"]:
		cat_tree_buy.text = "Owned"
		cat_tree_buy.disabled = true
	else:
		cat_tree_buy.text = "$" + str(prices["CatTree"])
		
	if owned_items["Chair"]:
		chair_buy.text = "Owned"
		chair_buy.disabled = true
	else:
		chair_buy.text = "$" + str(prices["Chair"])


func buy_cosmetic(item_name: String):
	var price = prices[item_name]
	
	if player.money >= price and not owned_items[item_name]:
		player.money -= price
		owned_items[item_name] = true
		
		var item_sprite = cosmetics.get_node(item_name)
		item_sprite.visible = true
		
		update_shop_ui()
	else:
		print("Not enough money or already owned")
