extends Node

@onready var mg_manager = $MinigameManager
@onready var hit_btn = $MinigameUI/HitButton
@onready var stand_btn = $MinigameUI/StandButton
@onready var minigame_ui = $MinigameUI
@onready var player_hand_container = $MinigameUI/PlayerHand
@onready var dealer_hand_container = $MinigameUI/DealerHand
@onready var player_score_label = $MinigameUI/PlayerScoreLabel
@onready var dealer_score_label = $MinigameUI/DealerScoreLabel
@onready var dealer_hand_label = $MinigameUI/DealerHandLabel
@onready var status_label = $MinigameUI/StatusLabel
@onready var current_bet_label = $MinigameUI/CurrentBetLabel
@onready var result_panel = $MinigameUI/ResultPanel
@onready var result_text = $MinigameUI/ResultPanel/ResultText
@onready var betting_panel = $MinigameUI/BettingPanel
@onready var bet_10_btn = $MinigameUI/BettingPanel/Bet10
@onready var bet_50_btn = $MinigameUI/BettingPanel/Bet50
@onready var bet_100_btn = $MinigameUI/BettingPanel/Bet100
@onready var bet_all_in_btn = $MinigameUI/BettingPanel/BetAllIn
@onready var fish_sprite = $MinigameUI/Control/FishSprite

var card_scene = preload("res://scenes/card_display.tscn")

# Fish textures
var fish_neutral = preload("res://assets/fish/angler/angler1.png")
var fish_annoyed = preload("res://assets/fish/angler/angler2.png")
var fish_worried = preload("res://assets/fish/angler/angler3.png")

func _ready():
	minigame_ui.visible = false
	result_panel.visible = false
	
	print("Minigame controller ready")
	print("Hit button: ", hit_btn)
	print("Stand button: ", stand_btn)

	hit_btn.pressed.connect(_on_hit)
	stand_btn.pressed.connect(_on_stand)
	
	# Connect betting buttons
	bet_10_btn.pressed.connect(func(): _on_bet_selected(10))
	bet_50_btn.pressed.connect(func(): _on_bet_selected(50))
	bet_100_btn.pressed.connect(func(): _on_bet_selected(100))
	bet_all_in_btn.pressed.connect(func(): _on_bet_selected(mg_manager.player_score))
	
	print("Buttons connected")

	mg_manager.cur_game_finished.connect(_on_game_finished)
	mg_manager.caught_fish.connect(_on_caught_fish)
	mg_manager.lost_fish.connect(_on_lost_fish)
	mg_manager.score_updated.connect(_on_score_updated)

func _start_minigame():
	print("Starting minigame session")
	minigame_ui.visible = true
	fish_sprite.texture = fish_neutral
	status_label.text = "HIT OR STAND?"
	_update_fish_name()
	_initialize_score_labels()
	_show_betting_ui()

func _initialize_score_labels():
	# Initialize dealer score label with fish name
	var fish_name = _get_fish_name()
	dealer_score_label.text = "%s Score: ?" % fish_name
	player_score_label.text = "Player Score: 0"

func _get_fish_name() -> String:
	# Extract fish name from texture path
	var texture_path = fish_neutral.resource_path
	var path_parts = texture_path.split("/")
	
	if path_parts.size() >= 3:
		var fish_name = path_parts[path_parts.size() - 2]
		var words = fish_name.split(" ")
		var capitalized_name = ""
		for word in words:
			if word.length() > 0:
				capitalized_name += word.capitalize() + " "
		return capitalized_name.strip_edges()
	else:
		return "Dealer"

func _update_fish_name():
	dealer_hand_label.text = _get_fish_name().to_upper()

func _start_game():
	print("Starting new round")
	result_panel.visible = false
	_clear_hands()
	_enable_buttons()
	_hide_betting_ui()
	_update_round_display()
	current_bet_label.text = "Bet: %d" % mg_manager.cur_game_bet
	current_bet_label.visible = true
	print("Buttons enabled - disabled state: Hit=", hit_btn.disabled, " Stand=", stand_btn.disabled)
	_update_display()

func _update_round_display():
	var round_label = $MinigameUI/ProgressMeter/RoundLabel
	round_label.text = "Round: %d/%d" % [mg_manager.cur_game_num, mg_manager.max_game_num]

func _on_hit():
	print("HIT BUTTON PRESSED!")
	mg_manager.current_game.hit()
	_update_display()
	
	if mg_manager.current_game.is_player_bust:
		_disable_buttons()
		await get_tree().create_timer(0.5).timeout
		mg_manager.finish_game()

func _on_stand():
	print("STAND BUTTON PRESSED!")
	mg_manager.current_game.stand()
	_update_display()
	_disable_buttons()
	await get_tree().create_timer(1.0).timeout
	mg_manager.finish_game()

func _on_game_finished(score: int, total_score: int, winner: String):
	var result_message = ""
	
	match winner:
		"player":
			result_message = "YOU WIN!"
			_update_fish_emotion()
		"dealer":
			result_message = "DEALER WINS"
		"push":
			result_message = "PUSH - TIE"
	
	var score_text = "+%d" % score if score > 0 else str(score)
	result_text.text = "%s\nScore: %s\nTotal: %d" % [result_message, score_text, total_score]
	result_panel.visible = true

	await get_tree().create_timer(2.0).timeout
	result_panel.visible = false
	
	# chekc win/lose
	mg_manager.new_game()
	
	# show betting ui
	if mg_manager.player_score > 0 && mg_manager.player_score < mg_manager.score_to_catch && mg_manager.cur_game_num < mg_manager.max_game_num:
		_show_betting_ui()

func _on_caught_fish():
	print("CAUGHT FISH - YOU WIN!")
	status_label.text = "YOU CAUGHT THE FISH!"
	result_text.text = "VICTORY!\nYou caught the fish!"
	result_panel.visible = true
	fish_sprite.texture = fish_worried
	_disable_buttons()
	
	await get_tree().create_timer(3.0).timeout
	result_panel.visible = false
	minigame_ui.visible = false


func _on_lost_fish():
	print("LOST FISH - GAME OVER")
	status_label.text = "FISH GOT AWAY..."
	result_text.text = "GAME OVER\nThe fish got away!"
	result_panel.visible = true
	_disable_buttons()
	
	await get_tree().create_timer(3.0).timeout
	result_panel.visible = false
	minigame_ui.visible = false

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
	
	# create card displays
	for card in hand:
		var card_display = card_scene.instantiate()
		container.add_child(card_display)
		
		if card.visible:
			card_display.set_card(card.suit, card.rank)
		else:
			card_display.set_card_hidden()
	
	# update score label
	var label_prefix = ""
	if is_dealer:
		label_prefix = _get_fish_name() + " "
	else:
		label_prefix = "Player "
	
	if show_score:
		var score = 0
		for card in hand:
			if card.visible:
				if card.rank == "A":
					score += 11
				else:
					score += card.value
		
		# fooking ace 
		var aces = 0
		for card in hand:
			if card.visible && card.rank == "A":
				aces += 1
		
		while score > 21 && aces > 0:
			score -= 10
			aces -= 1
		
		score_label.text = "%sScore: %d" % [label_prefix, score]
	else:
		score_label.text = "%sScore: ?" % label_prefix

func _clear_hands():
	for child in player_hand_container.get_children():
		child.queue_free()
	for child in dealer_hand_container.get_children():
		child.queue_free()

func _disable_buttons():
	hit_btn.disabled = true
	stand_btn.disabled = true

func _enable_buttons():
	hit_btn.disabled = false
	stand_btn.disabled = false

func _show_betting_ui():
	betting_panel.visible = true
	hit_btn.visible = false
	stand_btn.visible = false
	_clear_hands()
	status_label.text = "Place Your Bet"
	current_bet_label.visible = false
	
	# udpate buttn based on cur score
	var current_score = mg_manager.player_score
	bet_10_btn.disabled = current_score < 10
	bet_50_btn.disabled = current_score < 50
	bet_100_btn.disabled = current_score < 100
	bet_all_in_btn.disabled = current_score <= 0

func _hide_betting_ui():
	betting_panel.visible = false
	hit_btn.visible = true
	stand_btn.visible = true

func _on_bet_selected(bet_amount: int):
	print("Bet selected: ", bet_amount)
	# clamp bet to current score for all-in
	var actual_bet = min(bet_amount, mg_manager.player_score)
	mg_manager.set_bet(actual_bet)
	_start_game()

func _on_score_updated(current_score: int, target_score: int):
	var progress_bar = $MinigameUI/ProgressMeter/ProgressBar
	var score_label = $MinigameUI/ProgressMeter/ScoreLabel
	var round_label = $MinigameUI/ProgressMeter/RoundLabel
	
	progress_bar.max_value = target_score
	progress_bar.value = current_score
	score_label.text = "%d / %d" % [current_score, target_score]
	round_label.text = "Round: %d/%d" % [mg_manager.cur_game_num, mg_manager.max_game_num]
	
	_update_fish_emotion()

func _update_fish_emotion():
	var progress_percent = float(mg_manager.player_score) / float(mg_manager.score_to_catch)
	
	if progress_percent >= 0.8:
		fish_sprite.texture = fish_worried
	else:
		fish_sprite.texture = fish_neutral
