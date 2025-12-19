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
	return other.rank == rank and other.suit == suit
