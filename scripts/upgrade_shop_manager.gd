class_name UpgradeShopManager
extends Panel

@onready var player = $"../Player"
@onready var world_ui = $"../WorldUI"

@onready var reel_skill_level = $ScrollContainer/VBoxContainer/ReelSkill/Level
@onready var luck_level = $ScrollContainer/VBoxContainer/Luck/Level
@onready var salesman_level = $ScrollContainer/VBoxContainer/Salesman/Level

@onready var reel_skill_buy = $ScrollContainer/VBoxContainer/ReelSkill/Buy
@onready var luck_buy = $ScrollContainer/VBoxContainer/Luck/Buy
@onready var salesman_buy = $ScrollContainer/VBoxContainer/Salesman/Buy
@onready var power1_buy = $ScrollContainer/VBoxContainer/Power1/Buy
@onready var power2_buy = $ScrollContainer/VBoxContainer/Power2/Buy
@onready var power3_buy = $ScrollContainer/VBoxContainer/Power3/Buy

@onready var close_btn = $Close

var prices = {
	reel_skill = 200.0,
	luck = 200.0,
	salesman = 300.0,
	power1 = 350.0,
	power2 = 500.0,
	power3 = 700.0,
}

signal shop_open
signal shop_close

func _ready() -> void:
	modulate.a = 0
	scale = Vector2(0.8, 0.8)
	
	await get_tree().process_frame
	hide()
	
	reel_skill_buy.pressed.connect(buy_reel_skill)
	luck_buy.pressed.connect(buy_luck)
	salesman_buy.pressed.connect(buy_salesman)
	power1_buy.pressed.connect(buy_power1)
	power2_buy.pressed.connect(buy_power2)
	power3_buy.pressed.connect(buy_power3)
	close_btn.pressed.connect(disable_shop)
	
	_setup_button_hover_effects()

func _setup_button_hover_effects():
	for button in [reel_skill_buy, luck_buy, salesman_buy, power1_buy, power2_buy, power3_buy]:
		if not button.mouse_entered.is_connected(_on_button_hover):
			button.mouse_entered.connect(_on_button_hover.bind(button))
			button.mouse_exited.connect(_on_button_unhover.bind(button))
	
	if not close_btn.mouse_entered.is_connected(_on_button_hover):
		close_btn.mouse_entered.connect(_on_button_hover.bind(close_btn))
		close_btn.mouse_exited.connect(_on_button_unhover.bind(close_btn))

func _on_button_hover(button: Control):
	if not button.disabled:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)

func _on_button_unhover(button: Control):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

func enable_shop():
	update_shop_ui()
	emit_signal("shop_open")
	show()
	world_ui.allow_input = false
	
	# animate shop entrance
	modulate.a = 0
	scale = Vector2(0.8, 0.8)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.4)

func disable_shop():
	emit_signal("shop_close")
	
	# animate shop exit
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	
	await tween.finished
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
		_button_press_animation(reel_skill_buy)
		player.money -= prices.reel_skill
		player.reel_skill += 10.0
		update_shop_ui()
	else:
		_shake_button(reel_skill_buy)
		print("Not enough money")

func buy_luck():
	if player.money >= prices.luck:
		_button_press_animation(luck_buy)
		player.money -= prices.luck
		player.luck += 10.0
		update_shop_ui()
	else:
		_shake_button(luck_buy)
		print("Not enough money")

func buy_salesman():
	if player.money >= prices.salesman:
		_button_press_animation(salesman_buy)
		player.money -= prices.salesman
		player.salesman += 1.0
		update_shop_ui()
	else:
		_shake_button(salesman_buy)
		print("Not enough money")

func buy_power1():
	if player.money >= prices.power1 and not player.power_ups.power1:
		_button_press_animation(power1_buy)
		player.money -= prices.power1
		player.power_ups.power1 = true
		update_shop_ui()
	else:
		_shake_button(power1_buy)
		print("Not enough money")

func buy_power2():
	if player.money >= prices.power2 and not player.power_ups.power2:
		_button_press_animation(power2_buy)
		player.money -= prices.power2
		player.power_ups.power2 = true
		update_shop_ui()
	else:
		_shake_button(power2_buy)
		print("Not enough money")

func buy_power3():
	if player.money >= prices.power3 and not player.power_ups.power3:
		_button_press_animation(power3_buy)
		player.money -= prices.power3
		player.power_ups.power3 = true
		update_shop_ui()
	else:
		_shake_button(power3_buy)
		print("Not enough money")

func _button_press_animation(button: Control):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func _shake_button(button: Control):
	var original_pos = button.position
	var tween = create_tween()
	tween.tween_property(button, "position:x", original_pos.x + 5, 0.05)
	tween.tween_property(button, "position:x", original_pos.x - 5, 0.05)
	tween.tween_property(button, "position:x", original_pos.x + 5, 0.05)
	tween.tween_property(button, "position:x", original_pos.x, 0.05)
