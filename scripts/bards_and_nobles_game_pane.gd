extends GamePane
class_name BardsAndNoblesGamePane

signal customer_turned_away(customer: CardData, next: CardData)
signal sale_made(customer: CardData, trade_in: CardData, standing_gain: int, next_customer: CardData)
signal game_started(customer: CardData, trade_in: CardData)
signal game_over(score: int)
