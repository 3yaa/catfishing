extends Node
@onready var RoundWin = $Audio/RoundWin
@onready var RoundLose = $Audio/RoundLose
@onready var Deal = $Audio/Deal
@onready var FishCaught = $Audio/FishCaught
@onready var CatCry = $Audio/CatCry
@onready var Stand = $Audio/Stand
@onready var PokerChip = $Audio/PokerChip
@onready var mg_manager = $MinigameManager
@onready var hit_btn = $MinigameUI/HitButton
@onready var stand_btn = $MinigameUI/StandButton
@onready var double_btn = $MinigameUI/DoubleButton
@onready var minigame_ui = $MinigameUI
@onready var player_hand_container = $MinigameUI/PlayerHand
@onready var dealer_hand_container = $MinigameUI/DealerHand
@onready var player_score_label = $MinigameUI/PlayerScoreLabel
@onready var dealer_score_label = $MinigameUI/DealerScoreLabel
@onready var dealer_hand_label = $MinigameUI/DealerHandLabel
@onready var status_label = $MinigameUI/StatusLabel
@onready var current_bet_container = $MinigameUI/CurrentBetContainer
@onready var current_bet_label = $MinigameUI/CurrentBetContainer/VBoxContainer/CurrentBetLabel
@onready var result_panel = $MinigameUI/ResultPanel
@onready var result_text = $MinigameUI/ResultPanel/ResultText
@onready var betting_panel = $MinigameUI/BettingPanel
@onready var bet_10_btn = $MinigameUI/BettingPanel/Bet10
@onready var bet_50_btn = $MinigameUI/BettingPanel/Bet50
@onready var bet_100_btn = $MinigameUI/BettingPanel/Bet100
@onready var bet_all_in_btn = $MinigameUI/BettingPanel/BetAllIn
@onready var fish_sprite = $MinigameUI/Control/FishSprite
@onready var fish = get_node("/root/Game/FishLogic")
@onready var rarity_label = $MinigameUI/RarityLabel
@onready var player = get_node("/root/Game/Player")

var card_scene = preload("res://scenes/card_display.tscn")

# fish textures - dynamically loaded based on rarity
var fish_neutral: Texture2D
var fish_annoyed: Texture2D
var fish_worried: Texture2D

# fish type mapping by rarity
var fish_types = {
	0: ["clown fish", "Sea Bass"], # COMMON - randomly selected
	1: "blue tang", # RARE
	2: "shark" # SUPER_RARE
}

var current_fish_rarity: int = 0

var fish_idle_time: float = 0.0
var player_idle_time: float = 0.0
var top_panel: ColorRect
var bottom_panel: ColorRect
var player_sprite: AnimatedSprite2D
var player_base_position: Vector2
var waiting_for_click: bool = false

func _ready():
	minigame_ui.visible = false
	result_panel.visible = false
	
	# panel ref
	top_panel = $MinigameUI/OpaqueBackground2
	bottom_panel = $MinigameUI/OpaqueBackground3
	
	# player ref
	var player_node = $MinigameUI/Player
	if player_node and player_node.has_node("AnimatedSprite2D"):
		player_sprite = player_node.get_node("AnimatedSprite2D")
		player_base_position = player_sprite.position
	
	hit_btn.pressed.connect(_on_hit)
	stand_btn.pressed.connect(_on_stand)
	double_btn.pressed.connect(_on_double)
	
	# connect betting buttons
	bet_10_btn.pressed.connect(func(): _on_bet_selected(10))
	bet_50_btn.pressed.connect(func(): _on_bet_selected(50))
	bet_100_btn.pressed.connect(func(): _on_bet_selected(100))
	bet_all_in_btn.pressed.connect(func(): _on_bet_selected(mg_manager.player_score))
	
	mg_manager.cur_game_finished.connect(_on_game_finished)
	mg_manager.caught_fish.connect(_on_caught_fish)
	mg_manager.lost_fish.connect(_on_lost_fish)
	mg_manager.score_updated.connect(_on_score_updated)

func _process(delta: float):
	if minigame_ui.visible:
		_animate_fish(delta)
		_animate_player(delta)

func _reset_minigame_state():
	# cancel any pending click waits
	waiting_for_click = false
	
	# ensure all panels are in correct state
	result_panel.visible = false
	result_panel.modulate.a = 1.0
	betting_panel.visible = false
	current_bet_container.visible = false
	hit_btn.visible = false
	stand_btn.visible = false
	double_btn.visible = false
	
	# clear hands
	_clear_hands()
	
	print("Minigame state reset complete")

func _start_minigame():
	print("===STARTING MINIGAME===")
	print("Current game num: ", mg_manager.cur_game_num)
	print("Player score: ", mg_manager.player_score)
	print("Target score: ", mg_manager.score_to_catch)
	
	# reset all state from previous minigame
	_reset_minigame_state()
	
	minigame_ui.visible = true
	
	# load fish based on current_fish rarity
	if fish.current_fish:
		current_fish_rarity = fish.current_fish.fish_rarity
		_load_fish_textures(current_fish_rarity)
	
	# 
	player_sprite.play("fishing")
	# 
	fish_sprite.texture = fish_neutral
	status_label.text = "HIT OR STAND?"
	_update_fish_name()
	_update_rarity_label()
	_initialize_score_labels()
	# animate panel
	_animate_panels_in()
	# 
	await get_tree().create_timer(0.8).timeout
	_show_betting_ui()

func _animate_panels_in():
	# start panels off-screen
	top_panel.position.y = - top_panel.size.y
	bottom_panel.position.y = get_viewport().size.y
	# animate top panel sliding down
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	# 
	tween.tween_property(top_panel, "position:y", 0, 0.6)
	tween.tween_property(bottom_panel, "position:y", get_viewport().size.y - bottom_panel.size.y, 0.6)

func _animate_fish(delta: float):
	fish_idle_time += delta
	# floating motion
	var float_offset_y = sin(fish_idle_time * 1.5) * 15.0
	var float_offset_x = cos(fish_idle_time * 0.8) * 8.0
	# rotation
	var rotation_offset = sin(fish_idle_time * 1.2) * 0.05
	# base position -- CHANGE IF WANT SMT DIF
	var base_x = -158.0
	var base_y = -548.0
	# 
	fish_sprite.position.x = base_x + float_offset_x
	fish_sprite.position.y = base_y + float_offset_y
	fish_sprite.rotation = rotation_offset

func _animate_player(delta: float):
	if player_sprite:
		player_idle_time += delta
		# rocking motion
		var rock_y = sin(player_idle_time * 1.3) * 2.5
		var rock_x = cos(player_idle_time * 0.9) * 1.5
		var rock_rotation = sin(player_idle_time * 1.1) * 0.02
		
		player_sprite.position = player_base_position + Vector2(rock_x, rock_y)
		player_sprite.rotation = rock_rotation

# init dealer with fish
func _initialize_score_labels():
	var fish_name = _get_fish_name()
	dealer_score_label.text = "%s Hand: ?" % fish_name
	player_score_label.text = "Player Hand: 0"

func _load_fish_textures(rarity: int):
	var fish_type_data = fish_types.get(rarity, "clown fish")
	var fish_type = ""
	
	# handle common rarity with multiple fish types
	if fish_type_data is Array:
		fish_type = fish_type_data[randi() % fish_type_data.size()]
	else:
		fish_type = fish_type_data
	
	var base_path = "res://assets/fish/%s/" % fish_type
	
	# load the three emotion states
	if fish_type == "blue tang":
		fish_neutral = load(base_path + "blueTang1.png")
		fish_annoyed = load(base_path + "blueTang2.png")
		fish_worried = load(base_path + "blueTang3.png")
	elif fish_type == "clown fish":
		fish_neutral = load(base_path + "clown1.png")
		fish_annoyed = load(base_path + "clown2.png")
		fish_worried = load(base_path + "clown3.png")
	elif fish_type == "Sea Bass":
		fish_neutral = load(base_path + "seaBass1.png")
		fish_annoyed = load(base_path + "seaBass2.png")
		fish_worried = load(base_path + "seaBass3.png")
	elif fish_type == "shark":
		fish_neutral = load(base_path + "shark1.png")
		fish_annoyed = load(base_path + "shark2.png")
		fish_worried = load(base_path + "shark3.png")

func _get_fish_name() -> String:
	if fish_neutral and fish_neutral.resource_path:
		var texture_path = fish_neutral.resource_path
		var path_parts = texture_path.split("/")
		# 
		if path_parts.size() >= 3:
			var fish_name = path_parts[path_parts.size() - 2]
			var words = fish_name.split(" ")
			var capitalized_name = ""
			for word in words:
				if word.length() > 0:
					capitalized_name += word.capitalize() + " "
			return capitalized_name.strip_edges()
	return "Dealer"

func _update_rarity_label():
	var rarity_names = {
		0: "COMMON",
		1: "RARE",
		2: "SUPER RARE"
	}
	var rarity_colors = {
		0: Color(0.7, 0.7, 0.7), # gray for common
		1: Color(0.3, 0.6, 1.0), # blue for rare
		2: Color(1.0, 0.8, 0.0) # gold for super rare
	}
	
	rarity_label.text = rarity_names.get(current_fish_rarity, "COMMON")
	rarity_label.modulate = rarity_colors.get(current_fish_rarity, Color.WHITE)
	
	# animate rarity label entrance
	rarity_label.scale = Vector2(0.5, 0.5)
	rarity_label.modulate.a = 0
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(rarity_label, "scale", Vector2(1.0, 1.0), 0.5)
	tween.parallel().tween_property(rarity_label, "modulate:a", 1.0, 0.5)

func _update_fish_name():
	dealer_hand_label.text = _get_fish_name().to_upper()

func _start_game():
	print("Starting new round")
	result_panel.visible = false
	_clear_hands()
	_enable_buttons()
	_hide_betting_ui()
	_update_round_display()
	current_bet_label.text = str(mg_manager.cur_game_bet)
	# animate bet
	current_bet_container.visible = true
	current_bet_container.modulate.a = 0
	current_bet_container.scale = Vector2(0.8, 0.8)
	# 
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(current_bet_container, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(current_bet_container, "scale", Vector2(1.0, 1.0), 0.3)

	_update_display()

func _update_round_display():
	var round_label = $MinigameUI/ProgressMeter/RoundLabel
	round_label.text = "Round: %d/%d" % [mg_manager.cur_game_num, mg_manager.max_game_num]

func _on_hit():
	Deal.play()
	print("HIT BUTTON PRESSED!")
	_button_press_animation(hit_btn)
	mg_manager.current_game.hit()
	_update_display()
	
	if mg_manager.current_game.is_player_bust:
		_disable_buttons()
		await get_tree().create_timer(0.5).timeout
		mg_manager.finish_game()

func _on_stand():
	Stand.play()
	print("STAND BUTTON PRESSED!")
	_button_press_animation(stand_btn)
	mg_manager.current_game.stand(fish)
	_update_display()
	_disable_buttons()
	await get_tree().create_timer(1.0).timeout
	mg_manager.finish_game()

func _on_double():
	PokerChip.play()
	print("DOUBLE BUTTON PRESSED!")
	_button_press_animation(double_btn)
	
	# double bet
	var new_bet = mg_manager.cur_game_bet * 2
	mg_manager.cur_game_bet = new_bet
	
	# update bet display
	current_bet_label.text = str(new_bet)
	
	# animate
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(current_bet_container, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(current_bet_container, "scale", Vector2(1.0, 1.0), 0.3)
	
	# hide --- single use per round
	double_btn.visible = false

func _button_press_animation(button: Control):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_game_finished(score: int, total_score: int, winner: String):
	var result_message = ""
	# 
	match winner:
		"player":
			result_message = "YOU WIN!"
			_update_fish_emotion()
			RoundWin.play()
			
		"dealer":
			result_message = "DEALER WINS"
			RoundLose.play()
		"push":
			result_message = "PUSH - TIE"
	# 
	var score_text = "+%d" % score if score > 0 else str(score)
	result_text.text = "%s\nScore: %s\nTotal: %d\n\nClick to continue" % [result_message, score_text, total_score]
	# aniamte result
	result_panel.scale = Vector2(0.5, 0.5)
	result_panel.modulate.a = 0
	result_panel.visible = true
	# 
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(result_panel, "scale", Vector2(1.0, 1.0), 0.4)
	tween.parallel().tween_property(result_panel, "modulate:a", 1.0, 0.4)
	
	# wait for click
	await _wait_for_click()
	
	# fade out result
	var fade_tween = create_tween()
	fade_tween.tween_property(result_panel, "modulate:a", 0.0, 0.3)
	await fade_tween.finished
	result_panel.visible = false
	result_panel.modulate.a = 1.0
	
	# chekc win/lose
	mg_manager.new_game()
	
	# show betting ui
	if mg_manager.player_score > 0 and mg_manager.player_score < mg_manager.score_to_catch and mg_manager.cur_game_num <= mg_manager.max_game_num:
		_show_betting_ui()

func _on_caught_fish():
	FishCaught.play()
	print("CAUGHT FISH - YOU WIN!")
	
	# immediately hide the minigame
	minigame_ui.visible = false
	
	# show victory popup
	status_label.text = "YOU CAUGHT THE FISH!"
	result_text.text = "VICTORY!\nYou caught the fish!\n\nClick to continue"
	result_panel.visible = true
	fish_sprite.texture = fish_worried
	_disable_buttons()
	
	# make result panel visible
	result_panel.get_parent().remove_child(result_panel)
	get_parent().add_child(result_panel)
	
	await _wait_for_click()
	
	# cleanup
	get_parent().remove_child(result_panel)
	minigame_ui.add_child(result_panel)
	result_panel.visible = false


func _on_lost_fish():
	CatCry.play()
	
	
	print("LOST FISH - GAME OVER")
	
	# immediately hide the minigame to prevent any further interaction
	minigame_ui.visible = false
	
	# show game over popup
	status_label.text = "FISH GOT AWAY..."
	result_text.text = "GAME OVER\nThe fish got away!\n\nClick to continue"
	result_panel.visible = true
	_disable_buttons()
	
	# make result panel visible even when minigame_ui is hidden
	result_panel.get_parent().remove_child(result_panel)
	get_parent().add_child(result_panel)
	
	await _wait_for_click()
	
	# cleanup
	get_parent().remove_child(result_panel)
	minigame_ui.add_child(result_panel)
	result_panel.visible = false

func _update_display():
	var game = mg_manager.current_game
	
	# display both hands
	_display_hand(game.player_hand, player_hand_container, player_score_label, true, false)
	_display_hand(game.dealer_hand, dealer_hand_container, dealer_score_label, game.is_standing, true)
	
	# status update
	if game.is_player_bust:
		status_label.text = "BUST - YOU LOSE!"
	elif game.is_dealer_bust:
		status_label.text = "DEALER BUST - YOU WIN!"
	elif game.is_standing:
		status_label.text = "DEALER'S TURN"
	else:
		status_label.text = "HIT OR STAND?"

func _display_hand(hand: Array, container: Container, score_label: Label, show_score: bool, is_dealer: bool):
	# clear existing cards
	for child in container.get_children():
		child.queue_free()
	
	# create card displays with animation
	var card_index = 0
	for card in hand:
		var card_display = card_scene.instantiate()
		container.add_child(card_display)
		
		# if card peek powerup
		var should_reveal = card.visible or (is_dealer and player.power_ups.power3)
		
		if should_reveal:
			card_display.set_card(card.suit, card.rank)
		else:
			card_display.set_card_hidden()
		
		# card animation
		card_display.modulate.a = 0
		card_display.scale = Vector2(0.5, 0.5)
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		
		# card delay for animation
		tween.tween_property(card_display, "modulate:a", 1.0, 0.3).set_delay(0.1 * card_index)
		tween.parallel().tween_property(card_display, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.1 * card_index)
		
		card_index += 1
	
	# score label update
	var label_prefix = ""
	if is_dealer:
		label_prefix = _get_fish_name() + " "
	else:
		label_prefix = "Player "
	
	# calcualte visible card score
	var visible_score = 0
	var visible_aces = 0
	var has_hidden_cards = false
	
	for card in hand:
		if card.visible:
			if card.rank == "A":
				visible_score += 11
				visible_aces += 1
			else:
				visible_score += card.value
		else:
			has_hidden_cards = true
	
	# adj for aces
	while visible_score > 21 and visible_aces > 0:
		visible_score -= 10
		visible_aces -= 1
	
	# show score
	if show_score:
		score_label.text = "%sHand: %d" % [label_prefix, visible_score]
	else:
		# dealer with hidden cards
		if is_dealer and has_hidden_cards:
			# card peak->show full score
			if player.power_ups.power3:
				var full_score = 0
				var full_aces = 0
				for card in hand:
					if card.rank == "A":
						full_score += 11
						full_aces += 1
					else:
						full_score += card.value
				
				while full_score > 21 and full_aces > 0:
					full_score -= 10
					full_aces -= 1
				
				score_label.text = "%sHand: %d" % [label_prefix, full_score]
			else:
				score_label.text = "%sHand: %d + ?" % [label_prefix, visible_score]
		else:
			score_label.text = "%sHand: ?" % label_prefix

func _clear_hands():
	for child in player_hand_container.get_children():
		child.queue_free()
	for child in dealer_hand_container.get_children():
		child.queue_free()

func _disable_buttons():
	hit_btn.disabled = true
	stand_btn.disabled = true
	double_btn.disabled = true

func _enable_buttons():
	hit_btn.disabled = false
	stand_btn.disabled = false
	double_btn.disabled = false

func _show_betting_ui():
	betting_panel.visible = true
	hit_btn.visible = false
	stand_btn.visible = false
	double_btn.visible = false
	_clear_hands()
	
	# reset score labels
	var fish_name = _get_fish_name()
	dealer_score_label.text = "%s Hand: ?" % fish_name
	player_score_label.text = "Player Hand: 0"
	
	status_label.text = "Place Your Bet"
	current_bet_container.visible = false
	
	# move status label up for betting
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(status_label, "position:y", status_label.position.y - 100, 0.3)
	
	# animate betting in
	betting_panel.scale = Vector2(0.8, 0.8)
	betting_panel.modulate.a = 0
	
	var tween2 = create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_trans(Tween.TRANS_BACK)
	tween2.tween_property(betting_panel, "scale", Vector2(1.0, 1.0), 0.4)
	tween2.parallel().tween_property(betting_panel, "modulate:a", 1.0, 0.4)
	
	# 
	_setup_chip_hover_effects()
	
	# Update button states based on current score
	var current_score = mg_manager.player_score
	_update_chip_state(bet_10_btn, current_score >= 10)
	_update_chip_state(bet_50_btn, current_score >= 50)
	_update_chip_state(bet_100_btn, current_score >= 100)
	_update_chip_state(bet_all_in_btn, current_score > 0)

func _update_chip_state(chip: TextureButton, can_afford: bool):
	chip.disabled = not can_afford
	
	if can_afford:
		chip.modulate = Color(1.0, 1.0, 1.0, 1.0)
		chip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		chip.modulate = Color(0.4, 0.4, 0.4, 0.6)
		chip.mouse_default_cursor_shape = Control.CURSOR_ARROW

func _setup_chip_hover_effects():
	for chip in [bet_10_btn, bet_50_btn, bet_100_btn, bet_all_in_btn]:
		if not chip.mouse_entered.is_connected(_on_chip_hover):
			chip.mouse_entered.connect(_on_chip_hover.bind(chip))
		if not chip.mouse_exited.is_connected(_on_chip_unhover):
			chip.mouse_exited.connect(_on_chip_unhover.bind(chip))

func _on_chip_hover(chip: Control):
	if not chip.disabled:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(chip, "scale", Vector2(1.15, 1.15), 0.2)

func _on_chip_unhover(chip: Control):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(chip, "scale", Vector2(1.0, 1.0), 0.2)

func _hide_betting_ui():
	betting_panel.visible = false
	
	# move status label down for hit and miss
	var label_tween = create_tween()
	label_tween.set_ease(Tween.EASE_OUT)
	label_tween.set_trans(Tween.TRANS_CUBIC)
	label_tween.tween_property(status_label, "position:y", status_label.position.y + 100, 0.3)
	
	# animate action buttons
	hit_btn.visible = true
	stand_btn.visible = true
	double_btn.visible = true
	hit_btn.modulate.a = 0
	stand_btn.modulate.a = 0
	double_btn.modulate.a = 0
	hit_btn.scale = Vector2(0.8, 0.8)
	stand_btn.scale = Vector2(0.8, 0.8)
	double_btn.scale = Vector2(0.8, 0.8)
	
	var button_tween = create_tween()
	button_tween.set_parallel(true)
	button_tween.set_ease(Tween.EASE_OUT)
	button_tween.set_trans(Tween.TRANS_BACK)
	
	button_tween.tween_property(hit_btn, "modulate:a", 1.0, 0.4).set_delay(0.1)
	button_tween.tween_property(hit_btn, "scale", Vector2(1.0, 1.0), 0.4).set_delay(0.1)
	button_tween.tween_property(stand_btn, "modulate:a", 1.0, 0.4).set_delay(0.2)
	button_tween.tween_property(stand_btn, "scale", Vector2(1.0, 1.0), 0.4).set_delay(0.2)
	button_tween.tween_property(double_btn, "modulate:a", 1.0, 0.4).set_delay(0.15)
	button_tween.tween_property(double_btn, "scale", Vector2(1.0, 1.0), 0.4).set_delay(0.15)
	# 
	_setup_action_button_hover()

func _setup_action_button_hover():
	if not hit_btn.mouse_entered.is_connected(_on_action_button_hover):
		hit_btn.mouse_entered.connect(_on_action_button_hover.bind(hit_btn))
		hit_btn.mouse_exited.connect(_on_action_button_unhover.bind(hit_btn))
		stand_btn.mouse_entered.connect(_on_action_button_hover.bind(stand_btn))
		stand_btn.mouse_exited.connect(_on_action_button_unhover.bind(stand_btn))
		double_btn.mouse_entered.connect(_on_action_button_hover.bind(double_btn))
		double_btn.mouse_exited.connect(_on_action_button_unhover.bind(double_btn))

func _on_action_button_hover(button: Control):
	if not button.disabled:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)

func _on_action_button_unhover(button: Control):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)

func _on_bet_selected(bet_amount: int):
	PokerChip.play()
	print("Bet selected: ", bet_amount)
	
	# validate bet amount
	if bet_amount > mg_manager.player_score:
		print("Cannot afford bet of ", bet_amount, " with score ", mg_manager.player_score)
		return
	
	# clamp bet to current score for all-in
	var actual_bet = min(bet_amount, mg_manager.player_score)
	mg_manager.set_bet(actual_bet)
	
	# animate betting panel out
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(betting_panel, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(betting_panel, "scale", Vector2(0.8, 0.8), 0.3)
	
	await tween.finished
	_start_game()

func _on_score_updated(current_score: int, target_score: int):
	var progress_bar = $MinigameUI/ProgressMeter/ProgressBar
	var score_label = $MinigameUI/ProgressMeter/ScoreLabel
	var round_label = $MinigameUI/ProgressMeter/RoundLabel
	
	# aniamte progress bar change
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	progress_bar.max_value = target_score
	tween.tween_property(progress_bar, "value", current_score, 0.5)
	
	score_label.text = "%d / %d" % [current_score, target_score]
	round_label.text = "Round: %d/%d" % [mg_manager.cur_game_num, mg_manager.max_game_num]
	
	# add pulsing effect when close to winning
	var progress_percent = float(current_score) / float(target_score)
	if progress_percent >= 0.8:
		_pulse_progress_bar(progress_bar)
	
	_update_fish_emotion()

func _pulse_progress_bar(progress_bar: ProgressBar):
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(progress_bar, "modulate", Color(1.5, 1.2, 1.0), 0.8)
	tween.tween_property(progress_bar, "modulate", Color(1.0, 1.0, 1.0), 0.8)

func _update_fish_emotion():
	var progress_percent = float(mg_manager.player_score) / float(mg_manager.score_to_catch)
	
	if progress_percent >= 0.8:
		fish_sprite.texture = fish_worried
	else:
		fish_sprite.texture = fish_neutral

func _wait_for_click() -> void:
	waiting_for_click = true
	
	# wait for any currently held mouse button to be released
	while Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and waiting_for_click:
		await get_tree().process_frame
	
	if not waiting_for_click:
		return
	
	# wait a couple frames to clear any lingering input events
	await get_tree().process_frame
	await get_tree().process_frame
	
	if not waiting_for_click:
		return
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# wait for a fresh click
	while waiting_for_click:
		if Input.is_action_just_pressed("ui_accept"):
			break
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			break
		await get_tree().process_frame
	
	waiting_for_click = false
