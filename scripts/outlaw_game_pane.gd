extends GamePane
class_name OutlawGamePane

# sum: the outlaw in question
# new_owner: who claimed it
# prev_owner: who did it belong to before
# new_owner NONE means escaped, owners opposite means claim was stolen
# new_owner PLAYER/NPC and prev NONE intuitive
signal outlaw_claimed(sum: int, new_owner: OutlawCross.Owner, prev_owner: OutlawCross.Owner)
signal bounty_collected(delta: int, is_player_turn: bool)
signal player_won()
signal player_lost()
