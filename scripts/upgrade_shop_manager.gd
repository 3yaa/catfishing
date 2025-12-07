class_name UpgradeShopManager
extends Panel

@onready var player = $"../Player"
@onready var world_ui = $"../WorldUI"

@onready var reel_skill_level = $ScrollContainer/VBoxContainer/ReelSkill/Level
@onready var luck_level = $ScrollContainer/VBoxContainer/Luck/Level
@onready var salesman_level = $ScrollContainer/VBoxContainer/Salesman/Level

@onready var reel_skill_buy =$ScrollContainer/VBoxContainer/ReelSkill/Buy
@onready var luck_buy = $ScrollContainer/VBoxContainer/Luck/Buy
@onready var salesman_buy = $ScrollContainer/VBoxContainer/Salesman/Buy
@onready var power1_buy = $ScrollContainer/VBoxContainer/Power1/Buy
@onready var power2_buy = $ScrollContainer/VBoxContainer/Power2/Buy
@onready var power3_buy = $ScrollContainer/VBoxContainer/Power3/Buy

@onready var close_btn = $Close

var prices = {
	reel_skill = 2.0,
	luck = 2.0,
	salesman = 2.0,
	power1 = 10.0,
	power2 = 10.0,
	power3 = 10.0,
}

signal shop_open
signal shop_close

func _ready() -> void:
	hide()
	reel_skill_buy.pressed.connect(buy_reel_skill)
	luck_buy.pressed.connect(buy_luck)
	salesman_buy.pressed.connect(buy_salesman)
	power1_buy.pressed.connect(buy_power1)
	power2_buy.pressed.connect(buy_power2)
	power3_buy.pressed.connect(buy_power3)
	close_btn.pressed.connect(disable_shop)
	

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
	reel_skill_level.text = str(player.reel_skill)
	luck_level.text = str(player.luck)
	salesman_level.text = str(player.salesman)
	
	reel_skill_buy.text = "$" + str(prices.reel_skill)
	luck_buy.text = "$" + str(prices.luck)
	salesman_buy.text = "$" + str(prices.salesman)
	
	if player.power_ups.power1:
		power1_buy.text = "Owned"
		power1_buy.disabled = true
	else:
		power1_buy.text = "$" + str(prices.power1)
		
	if player.power_ups.power2:
		power2_buy.text = "Owned"
		power2_buy.disabled = true
	else:
		power2_buy.text = "$" + str(prices.power2)
		
	if player.power_ups.power3:
		power3_buy.text = "Owned"
		power3_buy.disabled = true
	else:
		power3_buy.text = "$" + str(prices.power3)


func buy_reel_skill():
	if player.money >= prices.reel_skill:
		player.money -= prices.reel_skill
		player.reel_skill += 10.0
		update_shop_ui()
	else:
		print("Not enough money")
		

func buy_luck():
	if player.money >= prices.luck:
		player.money -= prices.luck
		player.luck += 10.0
		update_shop_ui()
	else:
		print("Not enough money")	
		
		
func buy_salesman():
	if player.money >= prices.salesman:
		player.money -= prices.salesman
		player.salesman += 1.0
		update_shop_ui()
	else:
		print("Not enough money")
		

func buy_power1():
	if player.money >= prices.power1 and not player.power_ups.power1:
		player.money -= prices.power1
		player.power_ups.power1 = true
		update_shop_ui()
	else:
		print("Not enough money")
		
		
func buy_power2():
	if player.money >= prices.power2 and not player.power_ups.power2:
		player.money -= prices.power2
		player.power_ups.power2 = true
		update_shop_ui()
	else:
		print("Not enough money")
		
		
func buy_power3():
	if player.money >= prices.power3 and not player.power_ups.power3:
		player.money -= prices.power3
		player.power_ups.power3 = true
		update_shop_ui()
	else:
		print("Not enough money")
