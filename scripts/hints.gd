extends Control

@onready var tutorial = get_node("/root/Game/Tutorial_Manager")
@onready var camera = get_node("/root/Game/Camera2D")
@onready var label = get_node("/root/Game/Player/Text_Manager/Hint")

var hints = [
	"Rescue cats to unlock shops!",
	"A higher reel level makes fish show up faster!",
	"A higher Luck level makes rarer fish appear more often!",
	"A higher salesman level helps you sell fish for more!",
	"Make sure not to stay out late, or you will be teleported back!",
	"Rarer fish sell for much more money!",
	"Use powerups to beat tougher fish!",
	"Powerups can be bought from stores as you progress!",
	"Avoid hitting on high numbers, that can be dangerous!",
	"You don't have to win every match, win what you can!",
	"Rarer fish play more aggressively, so aim for higher numbers!",
]

var hint_no:int
var ongoing_hint = false

signal new_hint

func _ready():
	label.visible = false
	label.add_theme_color_override("font_color", Color.BLACK)
	self.connect("new_hint", _show_hint)
	

func _process(delta):
	if tutorial.tutorial_ongoing:
		pass
	else:
		if ongoing_hint:
			pass
		else:
			emit_signal("new_hint")
		
		
# 2~ hints per minute?
func _show_hint():
	ongoing_hint = true
	hint_no = randi() % hints.size()
	label.text = "Hint: " + hints[hint_no]
	label.visible = true
	await get_tree().create_timer(10.0).timeout
	label.visible = false
	await get_tree().create_timer(20.0).timeout
	ongoing_hint = false
