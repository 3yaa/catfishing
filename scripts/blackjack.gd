class_name Blackjack

enum GameState { BETTING, DEALING, PLAYER_TURN, DEALER_TURN, RESOLVE }

var deck: Deck = Deck.new()
var player_hand: Array[Card] = []
var fish_hand: Array[Card] = []
var game_state: GameState = GameState.DEALING

func _init():
	
