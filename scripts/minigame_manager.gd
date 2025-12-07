class_name MinigameManager
extends Node

@export var max_game_num: int = 4
@export var score_to_catch: int = 100

var current_game: Blackjack
var player_score: int = 0
var cur_game_bet: int = 10
var cur_game_num: int = 0

signal caught_fish
signal lost_fish
signal cur_game_finished(score: int, total_score: int, winner: String)

func _ready():
	new_game()

func new_game():
	# win condition
	if player_score >= score_to_catch:
		caught_fish.emit()
		return
	
	# lose condition
	if cur_game_num >= max_game_num:
		lost_fish.emit()
		return
	
	# new hand
	cur_game_num += 1
	current_game = Blackjack.new()

func finish_game():
	var winner = current_game.get_winner()
	var cur_game_score = 0
	
	if winner == "player":
		cur_game_score = int(cur_game_bet * _get_payout_multiplier())
	elif winner == "dealer":
		cur_game_score = - cur_game_bet
	
	player_score += cur_game_score
	cur_game_finished.emit(cur_game_score, player_score, winner)

# ------------ absolute garbage 
func _get_payout_multiplier() -> float:
	# check for blackjack (21 with 2 cards)
	if current_game.get_player_score() == 21 && current_game.player_hand.size() == 2:
		return 2.5
	
	return 2.0
