extends GamePane
class_name ZombieDiceGamePane

signal cards_drawn(survivors: Array[CardData], actions: Array[CardData])
signal round_lost(survivors: Array[CardData]) # 3 bullets drawn
signal round_won(survivors: Array[CardData]) # claimed results
