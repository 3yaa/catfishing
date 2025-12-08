extends Node2D


@onready var player = get_parent()
@onready var textbox: Texture2D = load("res://assets/background/TitleBackground.png")
@onready var hintbox: Texture2D = load("res://assets/background/TitleBackground.png")


var textbox_node
var hintbox_node

func _ready():
	textbox_node = Sprite2D.new()
	textbox_node.texture = textbox
	textbox_node.scale = Vector2(0.75, 0.1)
	add_child(textbox_node)
	textbox_node.visible = false
	
	hintbox_node = Sprite2D.new()
	hintbox_node.texture = hintbox
	hintbox_node.scale = Vector2(0.5, 0.05)
	add_child(hintbox_node)
	hintbox_node.visible = false
	

func _process(delta):
	if hintbox_node.visible:
		$Hint.position = Vector2(-$Hint.get_minimum_size().x / 2, -400)
		hintbox_node.position = Vector2($Hint.position.x + 200, $Hint.position.y + 10)
		hintbox_node.z_index = $Hint.z_index - 1	
	if textbox_node.visible:
		$Tutorial.position = Vector2(-$Tutorial.size.x / 2, -400)
		textbox_node.position = Vector2($Tutorial.position.x + 400, $Tutorial.position.y + 25)
		textbox_node.z_index = $Tutorial.z_index - 1	
