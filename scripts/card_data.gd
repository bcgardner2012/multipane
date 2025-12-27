extends Node
class_name CardData

enum Suit {
	HEARTS,
	DIAMONDS,
	CLUBS,
	SPADES
}

@export var suit: Suit
@export var rank: int # aces high
@export var texture: Texture2D

func equals(other: CardData) -> bool:
	return not other == null and other.rank == rank and other.suit == suit

func same_color(other: CardData) -> bool:
	return not other == null and other.is_red() == is_red()

func is_red() -> bool:
	return suit == Suit.HEARTS or suit == Suit.DIAMONDS

func is_black() -> bool:
	return suit == Suit.CLUBS or suit == Suit.SPADES

func same_suit(other: CardData) -> bool:
	return not other == null and other.suit == suit
