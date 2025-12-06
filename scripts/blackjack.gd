class_name Blackjack

var deck: Deck
var player_hand: Array[Deck.Card] = []
var dealer_hand: Array[Deck.Card] = []
var is_player_bust: bool = false
var is_dealer_bust: bool = false
var is_standing: bool = false
var is_dealer_turn: bool = false

func _init():
	_reset_game()

func _reset_game():
	player_hand.clear()
	dealer_hand.clear()
	is_player_bust = false
	is_dealer_bust = false
	is_standing = false
	is_dealer_turn = false
	
	# create a fresh deck for each game
	deck = Deck.new()
	
	# Deal initial cards
	player_hand.append(deck.draw_card())
	dealer_hand.append(deck.draw_card())
	player_hand.append(deck.draw_card())
	dealer_hand.append(deck.draw_card())
	
	# Hide dealer second card
	dealer_hand[1].visible = false

func is_finished() -> bool:
	return is_player_bust || (is_standing && is_dealer_turn)

func get_player_score() -> int:
	return _calculate_score(player_hand)

func get_dealer_score() -> int:
	return _calculate_score(dealer_hand)

func _calculate_score(hand: Array[Deck.Card]) -> int:
	var score = 0
	var aces = 0
	
	for card in hand:
		if card.rank == "A":
			aces += 1
			score += 11
		else:
			score += card.value
	
	# ace 
	while score > 21 && aces > 0:
		score -= 10
		aces -= 1
	
	return score

func hit():
	if is_finished() || is_standing:
		return
	
	player_hand.append(deck.draw_card())
	if get_player_score() > 21:
		is_player_bust = true

func stand():
	if is_standing:
		return
	
	is_standing = true
	# reveal dealer hidden ahdn
	dealer_hand[1].visible = true
	
	# dealer AI
	while get_dealer_score() < 17:
		dealer_hand.append(deck.draw_card())
	
	if get_dealer_score() > 21:
		is_dealer_bust = true
	
	is_dealer_turn = true

func get_winner() -> String:
	if is_player_bust:
		return "dealer"
	if is_dealer_bust:
		return "player"
	
	var player_score = get_player_score()
	var dealer_score = get_dealer_score()
	
	if player_score > dealer_score:
		return "player"
	elif dealer_score > player_score:
		return "dealer"
	else:
		return "push"