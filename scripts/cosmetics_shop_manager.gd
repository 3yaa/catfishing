class_name CosmeticsShopManager
extends Panel

@onready var player = $"../Player"
@onready var world_ui = $"../WorldUI"

@onready var close_btn = $Close

signal shop_open
signal shop_close

func _ready() -> void:
	hide()
	close_btn.pressed.connect(disable_shop)
	

func enable_shop():
	emit_signal("shop_open")
	show()
	world_ui.allow_input = false
	

func disable_shop():
	emit_signal("shop_close")
	hide()
	world_ui.allow_input = true
