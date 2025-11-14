class_name MinigameManager
extends Node

@export var max_game_num: int = 4
@export var score_to_catch: int = 100
# 
var current_game: Blackjack
var player_score: int = 10
var cur_game_bet: int = 0
var cur_game_num: int = 1
# 
signal caught_fish
signal lost_fish
signal cur_game_finished(score: int, total_score: int)

func _ready():
	new_game()

func new_game():
	# -- won
	if player_score >= score_to_catch:
		caught_fish.emit()
		return
	# -- lost
	if cur_game_num >= max_game_num:
		lost_fish.emit()
		return
	
	# new hand
	cur_game_num += 1
	current_game = Blackjack.new()

func finish_game():
	var cur_game_score = 0
	if not current_game.is_bust:
		cur_game_score = int(current_game.get_score() * _get_payout_multiplier())
	
	player_score += cur_game_score
	cur_game_finished.emit(cur_game_score, player_score)

	# await get_tree().create_timer(1.0).timeout
	new_game()

func _get_payout_multiplier() -> float:
	if current_game.is_bust:
		return 0.0
	# LOGIC FOR MULTIPLIER 
	return 1.0
