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
	"House": 1000,
	"CatTree": 400,
	"Chair": 400,
}

var owned_items = {
	"House": false,
	"CatTree": false,
	"Chair": false,
}

func _ready() -> void:
	modulate.a = 0
	scale = Vector2(0.8, 0.8)
	
	# force layout update
	await get_tree().process_frame
	hide()
	
	close_btn.pressed.connect(disable_shop)
	house_buy.pressed.connect(buy_cosmetic.bind("House"))
	cat_tree_buy.pressed.connect(buy_cosmetic.bind("CatTree"))
	chair_buy.pressed.connect(buy_cosmetic.bind("Chair"))
	
	_setup_button_hover_effects()

func _setup_button_hover_effects():
	for button in [house_buy, cat_tree_buy, chair_buy]:
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
	var button = get_button_for_item(item_name)
	
	if player.money >= price and not owned_items[item_name]:
		_button_press_animation(button)
		player.money -= price
		owned_items[item_name] = true
		
		var item_sprite = cosmetics.get_node(item_name)
		item_sprite.visible = true
		
		# animate the item appearing
		_animate_item_purchase(item_sprite)
		
		update_shop_ui()
	else:
		_shake_button(button)
		print("Not enough money or already owned")

func get_button_for_item(item_name: String) -> Button:
	match item_name:
		"House":
			return house_buy
		"CatTree":
			return cat_tree_buy
		"Chair":
			return chair_buy
	return null

func _animate_item_purchase(item_sprite: Node2D):
	if item_sprite:
		item_sprite.scale = Vector2(0.5, 0.5)
		item_sprite.modulate.a = 0
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(item_sprite, "scale", Vector2(1.0, 1.0), 0.5)
		tween.parallel().tween_property(item_sprite, "modulate:a", 1.0, 0.5)

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
