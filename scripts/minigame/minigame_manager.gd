class_name MinigameManager
extends Node

@export var max_game_num: int = 5
@onready var player = get_node("/root/Game/Player")

var score_to_catch: int = 500
var starting_score: int = 100
var current_game: Blackjack
var player_score: int = 0
var cur_game_bet: int = 0
var cur_game_num: int = 0

signal caught_fish
signal lost_fish
signal cur_game_finished(score: int, total_score: int, winner: String)
signal score_updated(current_score: int, target_score: int)

func initialize_minigame(target_score: int, start_score: int):
	score_to_catch = target_score
	starting_score = start_score
	player_score = starting_score
	cur_game_num = 0
	score_updated.emit(player_score, score_to_catch)

func new_game():
	# win condition
	if player_score >= score_to_catch:
		print("EMITTING caught_fish signal!")
		caught_fish.emit()
		player.fish_caught.emit()
		return
	
	# lose con - out of score
	if player_score <= 0:
		print("EMITTING lost_fish signal - out of score!")
		lost_fish.emit()
		return
	
	# lose con - out of rounds
	if cur_game_num >= max_game_num:
		print("EMITTING lost_fish signal - out of rounds!")
		lost_fish.emit()
		return
	
	# new hand
	cur_game_num += 1
	print("Starting round ", cur_game_num)
	current_game = Blackjack.new()

func set_bet(bet_amount: int):
	cur_game_bet = bet_amount

func finish_game():
	var winner = current_game.get_winner()
	var cur_game_score = 0
	
	if winner == "player":
		cur_game_score = int(cur_game_bet * _get_payout_multiplier())
	elif winner == "dealer":
		cur_game_score = - cur_game_bet
	
	player_score += cur_game_score
	score_updated.emit(player_score, score_to_catch)
	cur_game_finished.emit(cur_game_score, player_score, winner)

# Standard blackjack payouts
func _get_payout_multiplier() -> float:
	# Blackjack (natural 21 with 2 cards) pays 3:2
	if current_game.get_player_score() == 21 && current_game.player_hand.size() == 2:
		return 1.5
	
	# Regular win pays 1:1
	return 1.0
