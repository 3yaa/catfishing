extends TextureRect

func _ready():
	custom_minimum_size = Vector2(80, 120)
	expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func set_card(suit: String, rank: String):
	# converts score to asset
	var rank_str = rank
	if rank in ["2", "3", "4", "5", "6", "7", "8", "9"]:
		rank_str = "0" + rank
	
	# convert suit name to lowercase
	var suit_lower = suit.to_lower()
	
	# now build card path
	var card_path = "res://assets/Cards (large)/card_%s_%s.png" % [suit_lower, rank_str]
	
	# load texture
	texture = load(card_path)

func set_card_hidden():
	# back image of card
	var back_path = "res://assets/Cards (large)/card_back.png"
	texture = load(back_path)
