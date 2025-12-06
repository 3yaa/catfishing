extends PanelContainer

@onready var rank_label = $VBoxContainer/RankLabel
@onready var suit_label = $VBoxContainer/SuitLabel

func _ready():
	custom_minimum_size = Vector2(80, 120)

func set_card(suit: String, rank: String):
	rank_label.text = rank
	suit_label.text = suit
	
	var color = Color.WHITE
	if suit in ["Hearts", "Diamonds"]:
		color = Color.RED
	else:
		color = Color.BLACK
	
	suit_label.add_theme_color_override("font_color", color)
	rank_label.add_theme_color_override("font_color", color)

func set_card_hidden():
	rank_label.text = "?"
	suit_label.text = "?"
	
	var color = Color.DARK_GRAY
	suit_label.add_theme_color_override("font_color", color)
	rank_label.add_theme_color_override("font_color", color)
