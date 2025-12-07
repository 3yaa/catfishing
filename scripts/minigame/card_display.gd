extends TextureRect

func _ready():
	custom_minimum_size = Vector2(100, 140)
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func set_card(suit: String, rank: String):
	# Capitalize first letter of suit: Hearts, Diamonds, etc.
	var suit_capitalized = suit.capitalize()
	
	# Build the card path: cardHearts_A.png, cardDiamonds_5.png, etc.
	var card_path = "res://assets/Black Jack/cards/card%s_%s.png" % [suit_capitalized, rank]
	
	# Load the texture
	texture = load(card_path)
	if not texture:
		push_error("Card image not found: " + card_path)

func set_card_hidden():
	# Load the card back image
	var back_path = "res://assets/Black Jack/cards/cardBack.png"
	texture = load(back_path)
	if not texture:
		push_error("Card back image not found: " + back_path)
