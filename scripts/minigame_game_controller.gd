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
	# hide ui start
	minigame_ui.visible = false
	result_panel.visible = false

	# connect button signal
	hit_btn.pressed.connect(_on_hit)
	stand_btn.pressed.connect(_on_stand)

	# connect game signal
	mg_manager.cur_game_finished.connect(_on_game_finished)
	mg_manager.caught_fish.connect(_on_caught_fish)
	mg_manager.lost_fish.connect(_on_lost_fish)

	# start game
	mg_manager.new_game()
	_start_game()

func _start_game():
	minigame_ui.visible = true
	result_panel.visible = false
	_clear_hand()
	_enable_buttons()
	_update_display()

func _on_hit():
	mg_manager.current_game.hit();
	_update_display()
	if mg_manager.current_game.is_finished():
		_disable_buttons()
		await get_tree().create_timer(0.5).timeout
		mg_manager.finish_game()

func _on_stand():
	mg_manager.current_game.stand()
	_update_display()
	_disable_buttons()
	await get_tree().create_timer(0.5).timeout
	mg_manager.finish_game()

func _on_game_finished(score: int, total_score: int):
	var is_bust = mg_manager.current_game.is_bust
	var bust_text = "    BUST" if is_bust else ""
	result_text.text = "Hand Score: %d%s\nTotal Score: %d" % [score, bust_text, total_score]
	result_panel.visible = true

	await get_tree().create_timer(5).timeout
	minigame_ui.visible = false
	mg_manager.new_game()
	_start_game()

func _on_caught_fish():
	print("CAUGHT FISH")
	minigame_ui.visible = false
	# add score and stuff

func _on_lost_fish():
	print("LOST FISH")
	minigame_ui.visible = false
	# :'(

func _update_display():
	_display_hand(mg_manager.current_game.hand, player_hand_container, player_score_label);
	# 
	if mg_manager.current_game.is_bust:
		status_label.text = "BUST"
	elif mg_manager.current_game.is_standing:
		status_label.text = "STANDING"
	else:
		status_label.text = "HIT OR STAND"

func _display_hand(hand: Array, container: Container, score_label: Label):
	# clear existing
	for child in container.get_children():
		child.queue_free()
	
	# create card display
	for card in hand:
		var card_display = card_scene.instantiate()
		container.add_child(card_display)
		card_display.set_card(card.suit, card.rank)

func _clear_hand():
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
