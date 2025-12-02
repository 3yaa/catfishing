class_name Blackjack

var deck: Deck
var hand: Array[Deck.Card] = []
var is_bust: bool = false
var is_standing: bool = false

func _init():
	hand.clear()
	deck = Deck.new()
	hand.append(deck.draw_card())
	hand.append(deck.draw_card())

func is_finished() -> bool:
	return is_bust || is_standing
# 
func get_score() -> int:
	var score = 0
	for card in hand:
		score += card.value
	return score

func hit():
	if is_finished():
		return
	# 
	hand.append(deck.draw_card())
	if get_score() > 21:
		is_bust = true

func stand():
	is_standing = true
	
