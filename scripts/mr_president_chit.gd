extends TextureRect
class_name MrPresidentChit

static var _diamond_chit_texture: Texture2D = preload("res://assets/chits/diamond_chit.jpg")
static var _heart_chit_texture: Texture2D = preload("res://assets/chits/heart_chit.jpg")
static var _spade_chit_texture: Texture2D = preload("res://assets/chits/spade_chit.jpg")

var suit: CardData.Suit = CardData.Suit.CLUBS

# clubs are a default value and no player uses club cards
func set_suit(_suit: CardData.Suit) -> void:
	suit = _suit
	match suit:
		CardData.Suit.DIAMONDS:
			texture = _diamond_chit_texture
		CardData.Suit.HEARTS:
			texture = _heart_chit_texture
		CardData.Suit.SPADES:
			texture = _spade_chit_texture
	
