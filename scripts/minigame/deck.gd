class_name Deck

# individual card
class Card:
	var suit: String
	var rank: String
	var value: int
	var visible: bool

	func _init(s: String, r: String, v: int):
		suit = s
		rank = r
		value = v
		visible = true

# deck of cards
var cards: Array = []

func _init():
	_create_deck()
	shuffle()

func _create_deck():
	var suits = ["Hearts", "Diamonds", "Clubs", "Spades"]
	var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

	# create all cards and put into deck
	for suit in suits:
		for i in range(ranks.size()):
			var rank = ranks[i]
			
			var value
			if i < 9:
				value = i + 2
			elif i < 12:
				value = 10
			else:
				value = 11
			# put into deck
			cards.append(Card.new(suit, rank, value))

func shuffle():
	cards.shuffle()

func draw_card() -> Card:
	return cards.pop_back()
