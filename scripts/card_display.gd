extends PanelContainer

var card_texture: TextureRect

func _ready():
	custom_minimum_size = Vector2(80, 120)
	
	# Create TextureRect for displaying card images
	card_texture = TextureRect.new()
	card_texture.name = "CardTexture"
	card_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	card_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(card_texture)

func set_card(suit: String, rank: String):
	# Convert rank to match your file naming (2-10 need leading zeros)
	var rank_str = rank
	if rank in ["2", "3", "4", "5", "6", "7", "8", "9"]:
		rank_str = "0" + rank
	
	# Convert suit name to lowercase
	var suit_lower = suit.to_lower()
	
	# Build the card path: card_hearts_A, card_diamonds_02, etc.
	var card_path = "res://assets/Cards (large)/card_%s_%s.png" % [suit_lower, rank_str]
	
	# Try to load the texture
	var texture = load(card_path)
	if texture:
		card_texture.texture = texture
	else:
		# Fallback if image not found
		push_error("Card image not found: " + card_path)
		_show_text_card(suit, rank)

func set_card_hidden():
	# Load the card back image
	var back_path = "res://assets/Cards (large)/card_back.png"
	var texture = load(back_path)
	
	if texture:
		card_texture.texture = texture
	else:
		# Fallback if card back not found
		push_error("Card back image not found: " + back_path)
		_show_text_card("?", "?")

func _show_text_card(suit: String, rank: String):
	# Fallback to text display if images aren't found
	if card_texture:
		card_texture.queue_free()
