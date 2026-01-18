extends Node
class_name GamePlug

const QH_SUBDIR = "qh"
const QC_SUBDIR = "qc"
const QS_SUBDIR = "qs"
const QD_SUBDIR = "qd"
const KH_SUBDIR = "kh"
const KC_SUBDIR = "kc"
const KS_SUBDIR = "ks"
const KD_SUBDIR = "kd"
const JH_SUBDIR = "jh"
const JC_SUBDIR = "jc"
const JS_SUBDIR = "js"
const JD_SUBDIR = "jd"
const XH_SUBDIR = "xh"
const XC_SUBDIR = "xc"
const XS_SUBDIR = "xs"
const XD_SUBDIR = "xd"

@export var portrait: Portrait

func _get_suit_channel() -> int:
	return get_parent().suit_channel

func _card_to_notation(card: CardData) -> String:
	match card.suit:
		CardData.Suit.HEARTS:
			if card.rank == 10:
				return XH_SUBDIR
			if card.rank == 11:
				return JH_SUBDIR
			if card.rank == 12:
				return QH_SUBDIR
			if card.rank == 13:
				return KH_SUBDIR
		CardData.Suit.DIAMONDS:
			if card.rank == 10:
				return XD_SUBDIR
			if card.rank == 11:
				return JD_SUBDIR
			if card.rank == 12:
				return QD_SUBDIR
			if card.rank == 13:
				return KD_SUBDIR
		CardData.Suit.CLUBS:
			if card.rank == 10:
				return XC_SUBDIR
			if card.rank == 11:
				return JC_SUBDIR
			if card.rank == 12:
				return QC_SUBDIR
			if card.rank == 13:
				return KC_SUBDIR
		CardData.Suit.SPADES:
			if card.rank == 10:
				return XS_SUBDIR
			if card.rank == 11:
				return JS_SUBDIR
			if card.rank == 12:
				return QS_SUBDIR
			if card.rank == 13:
				return KS_SUBDIR
	return ""
