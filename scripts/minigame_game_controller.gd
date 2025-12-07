extends Node

@onready var mg_manager = $MinigameManager
@onready var hit_btn = $MinigameUI/HitButton
@onready var stand_btn = $MinigameUI/StandButton
@onready var minigame_ui = $MinigameUI
@onready var player_hand_container = $MinigameUI/PlayerHand
@onready var dealer_hand_container = $MinigameUI/DealerHand
@onready var player_score_label = $MinigameUI/PlayerScoreLabel
@onready var dealer_score_label = $MinigameUI/DealerScoreLabel
@onready var status_label = $MinigameUI/StatusLabel
@onready var result_panel = $MinigameUI/ResultPanel
@onready var result_text = $MinigameUI/ResultPanel/ResultText

var card_scene = preload("res://scenes/card_display.tscn")

func _ready():
	minigame_ui.visible = false
	result_panel.visible = false

	hit_btn.pressed.connect(_on_hit)
	stand_btn.pressed.connect(_on_stand)

	mg_manager.cur_game_finished.connect(_on_game_finished)
	mg_manager.caught_fish.connect(_on_caught_fish)
	mg_manager.lost_fish.connect(_on_lost_fish)

	mg_manager.new_game()
	_start_game()

func _start_game():
	minigame_ui.visible = true
	result_panel.visible = false
	_clear_hands()
	_enable_buttons()
	_update_display()

func _on_hit():
	mg_manager.current_game.hit()
	_update_display()
	
	if mg_manager.current_game.is_player_bust:
		_disable_buttons()
		await get_tree().create_timer(0.5).timeout
		mg_manager.finish_game()

func _on_stand():
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
		"dealer":
			result_message = "DEALER WINS"
		"push":
			result_message = "PUSH - TIE"
	
	var score_text = "+%d" % score if score > 0 else str(score)
	result_text.text = "%s\nScore: %s\nTotal: %d" % [result_message, score_text, total_score]
	result_panel.visible = true

	await get_tree().create_timer(3.0).timeout
	
	# check if game should continue ??? might be borken
	if mg_manager.player_score >= mg_manager.score_to_catch || mg_manager.cur_game_num >= mg_manager.max_game_num:
		return
		
	mg_manager.new_game()
	_start_game()

func _on_caught_fish():
	print("CAUGHT FISH - YOU WIN!")
	status_label.text = "YOU CAUGHT THE FISH!"
	result_text.text = "VICTORY!\nYou caught the fish!"
	result_panel.visible = true

	_disable_buttons()


func _on_lost_fish():
	print("LOST FISH - GAME OVER")
	status_label.text = "FISH GOT AWAY..."
	result_text.text = "GAME OVER\nThe fish got away!"
	result_panel.visible = true

	_disable_buttons()

func _update_display():
	var game = mg_manager.current_game
	
	# display both hands
	_display_hand(game.player_hand, player_hand_container, player_score_label, true)
	_display_hand(game.dealer_hand, dealer_hand_container, dealer_score_label, game.is_standing)
	
	# status update
	if game.is_player_bust:
		status_label.text = "BUST - YOU LOSE!"
	elif game.is_dealer_bust:
		status_label.text = "DEALER BUST - YOU WIN!"
	elif game.is_standing:
		status_label.text = "DEALER'S TURN"
	else:
		status_label.text = "HIT OR STAND?"

func _display_hand(hand: Array, container: Container, score_label: Label, show_score: bool):
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
	
	# Update score label
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
		
		score_label.text = "Score: %d" % score
	else:
		score_label.text = "Score: ?"

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
