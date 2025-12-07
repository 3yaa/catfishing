extends CanvasLayer

@export var dev_mode: bool = true

@onready var total_fish_label = $FishCounter/Total
@onready var common_fish_label = $FishCounter/Common
@onready var rare_fish_label = $FishCounter/Rare
@onready var super_rare_fish_label = $FishCounter/SuperRare

@onready var clock = $"../Clock"
@onready var player = $"../Player"
@onready var fish_logic = $"../FishLogic"

@onready var ui_clock_phase = $TimeOfDay/Phase
@onready var ui_clock_time = $TimeOfDay/Time
@onready var ui_warning = $WarningBox/Warning
@onready var ui_dialogue = $DialogueBox/Dialogue
@onready var ui_money = $Money/MoneyCount

# this is for handling opening sequence + cutscene 
var allow_input: bool = false

@onready var cutscene = get_parent().get_node("Cutscene_Manager")
@onready var tutorial = get_parent().get_node("Tutorial_Manager")

signal cutscene_start
signal tutorial_start

func _ready() -> void:
	await get_tree().process_frame
	
	if dev_mode:
		tutorial.tutorial_ongoing = false
	else:
		# Cutscene will play on ready:
		#emit_signal("cutscene_start")
		#await cutscene.cutscene_end
		# then tutorial
		emit_signal("tutorial_start")
		await tutorial.tutorial_end
		
	print("start main")
	# then normal game proceed
	allow_input = true
	# await tutorial end and whatnot
	await get_tree().process_frame
		
	update_fish_display()
	update_clock_display()
	

func _process(delta: float) -> void:
	if not tutorial.tutorial_ongoing:
		update_clock_display()
		update_warning_display()
		update_money_display()
		update_fish_display()

func update_fish_display() -> void:
	var total = fish_logic.get_total_fish_count()
	var common = fish_logic.get_fish_count_by_rarity(0)
	var rare = fish_logic.get_fish_count_by_rarity(1)
	var super_rare = fish_logic.get_fish_count_by_rarity(2)
	
	total_fish_label.text = "Fish: " + str(total)
	common_fish_label.text = "● " + str(common)
	rare_fish_label.text = "● " + str(rare)
	super_rare_fish_label.text = "★ " + str(super_rare)

# call when caught fish
func caught_fish() -> void:
	# player.is_fishing = false
	# set up this connection later
	update_fish_display()
	print("caught fish")
	
func update_money_display():
	ui_money.text = str(player.money)
	
func update_clock_display() -> void:
	if not tutorial.tutorial_ongoing:
		if clock.is_day:
			ui_clock_phase.text = "Day"
		else:
			ui_clock_phase.text = "Night"
		
		ui_clock_time.text = str(int(clock.get_remaining_time()))
	
func update_warning_display() -> void:
	if player.is_in_ocean and not clock.is_day:
		ui_warning.text = "It's getting late..."
	elif not player.is_in_ocean and not clock.is_day:
		ui_warning.text = "You can't enter the ocean at night"
	else:
		ui_warning.text = ""
		
func update_dialogue_display(text: String) -> void:
	ui_dialogue.text = text
