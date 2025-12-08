extends Label

@onready var debt:float = 10000.00

func _ready():
	visible = true

func update_debt(payment: float):
	debt -= payment
