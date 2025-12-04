class_name UpgradeShopManager
extends Panel

@onready var player = $"../Player"

@onready var reel_skill_level = $ReelSkillLevel
@onready var luck_level = $LuckLevel
@onready var salesman_level = $SalesmanLevel

@onready var reel_skill_buy = $ReelSkillBuy
@onready var luck_buy = $LuckBuy
@onready var salesman_buy = $SalesmanBuy

@onready var close_btn = $Close

var PRICE: float = 2.0

signal shop_open
signal shop_close

func _ready() -> void:
	hide()
	reel_skill_buy.pressed.connect(buy_reel_skill)
	luck_buy.pressed.connect(buy_luck)
	salesman_buy.pressed.connect(buy_salesman)
	close_btn.pressed.connect(disable_shop)
	

func enable_shop():
	update_shop_ui()
	emit_signal("shop_open")
	show()
	

func disable_shop():
	emit_signal("shop_close")
	hide()
	

func update_shop_ui():
	reel_skill_level.text = str(player.reel_skill)
	luck_level.text = str(player.luck)
	salesman_level.text = str(player.salesman)


func buy_reel_skill():
	if player.money >= PRICE:
		player.money -= PRICE
		player.reel_skill += 10.0
		update_shop_ui()
	else:
		print("Not enough money")
		

func buy_luck():
	if player.money >= PRICE:
		player.money -= PRICE
		player.luck += 10.0
		update_shop_ui()
	else:
		print("Not enough money")	
		
		
func buy_salesman():
	if player.money >= PRICE:
		player.money -= PRICE
		player.salesman += 1.0
		update_shop_ui()
	else:
		print("Not enough money")
