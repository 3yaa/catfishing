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

func _ready() -> void:
	modulate.a = 0
	scale = Vector2(0.8, 0.8)
	input.visible = false
	scanner.visible = false
	enter.visible = false
	invalid.visible = false
	invalid.add_theme_color_override("font_color", Color.RED)
	
	await get_tree().process_frame
	hide()
	
	sell_btn.pressed.connect(sell)
	close.pressed.connect(disable_shop)
	debt_btn.pressed.connect(open_debt)
	enter.pressed.connect(process_debt)
	
	_setup_button_hover_effects()


func open_debt():
	scanner.visible = true
	input.visible = true
	enter.visible = true
	invalid.visible = false
	scanner.position = Vector2(player.position.x, player.position.y - 900)
	input.text = ""
	
func process_debt():
	if input.text == "":
		scanner.visible = false
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


func _setup_button_hover_effects():
	if not sell_btn.mouse_entered.is_connected(_on_button_hover):
		sell_btn.mouse_entered.connect(_on_button_hover.bind(sell_btn))
		sell_btn.mouse_exited.connect(_on_button_unhover.bind(sell_btn))
	
	if not close.mouse_entered.is_connected(_on_button_hover):
		close.mouse_entered.connect(_on_button_hover.bind(close))
		close.mouse_exited.connect(_on_button_unhover.bind(close))

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
	scanner.visible = false
	await tween.finished
	hide()
	world_ui.allow_input = true
	

func update_shop_ui():
	ui_fish_count.text = str(fish_logic.fish_inventory.size())
	ui_fish_value.text = "$" + str(get_total_fish_value())


func sell():
	var fish_value = get_total_fish_value()
	
	if fish_logic.fish_inventory.size() == 0:
		_shake_button(sell_btn)
		print("No fish to sell")
		return
	
	_button_press_animation(sell_btn)
	print("Sell for $", fish_value)
	
	# animate the value increasing
	_animate_value_increase(fish_value)
	
	#debt.update_debt(fish_value)
	player.money += fish_value
	fish_logic.fish_inventory.clear()
	update_shop_ui()

func _animate_value_increase(value: float):
	var label = ui_fish_value
	var start_value = 0.0
	var duration = 0.5
	
	var tween = create_tween()
	tween.tween_method(func(val): label.text = "$%.2f" % val, start_value, value, duration)

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
	
	
func get_total_fish_value():
	var value = 0
	for fish in fish_logic.fish_inventory:
		value += fish.value
	return value
