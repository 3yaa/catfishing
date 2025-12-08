extends RichTextLabel

func _ready():
	visible = false
	autowrap_mode = TextServer.AUTOWRAP_WORD
	custom_minimum_size = Vector2(380, 800)
	position = Vector2(67.5, 160)
	add_theme_color_override("default_color", Color(0.0, 0.0, 0.0, 1.0))
	bbcode_enabled = true
	z_index = 10
	z_as_relative = false
	text = "[b]Basics:[/b]
1. Bet your score to reach the target threshold!
2. Reach 0 score or the last round, lose the fish!
3. The default target sum is 21!
4. Aces can be 1 or 11 interchangeably!
5. King, Queen, and Jack are 10!
6. Hit to get another card to increase your score!
7. Stand if you're satisfied with your cards!"
