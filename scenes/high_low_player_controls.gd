extends Control
class_name HighLowPlayerControls

signal player_guessed(guess: Guess)
signal player_guessed_wrong(was_same: bool)

enum Guess {
	HIGH,
	LOW
}

# The index in the selector must line up with the index in AIBrains node
@export var ai_enabled: bool
@export var suit_channel: int
@export var _signals: HighLowGamePane

var guess: Guess
var score: int

var brain: HighLowGameAI

func _on_robot_button_gui_input(event: InputEvent) -> void:
	if ClickHelper.is_left_click(event):
		ai_enabled = !ai_enabled
		if ai_enabled:
			# hide buttons, show ai selector
			$HighButton.visible = false
			$LowButton.visible = false
			$AISelector.visible = true
		else:
			# hide ai selector, show buttons
			$HighButton.visible = true
			$LowButton.visible = true
			$AISelector.visible = false


func _on_high_button_pressed() -> void:
	guess = Guess.HIGH
	player_guessed.emit(guess)

func _on_low_button_pressed() -> void:
	guess = Guess.LOW
	player_guessed.emit(guess)


func _on_high_low_game_player_evaluate_guesses(prev_card: CardData, next_card: CardData) -> void:
	if next_card.rank > prev_card.rank and guess == Guess.HIGH:
		_increment_score()
	elif next_card.rank < prev_card.rank and guess == Guess.LOW:
		_increment_score()
	else:
		# same or guessed wrong
		player_guessed_wrong.emit(next_card.rank == prev_card.rank)
		# externalize
		_signals.guessed_incorrectly.emit(suit_channel, next_card.rank == prev_card.rank)
	
	# set guess if ai_enabled and a brain has been assigned
	if ai_enabled and brain != null:
		guess = brain.generate_guess(prev_card, next_card)
		if guess == Guess.HIGH:
			$AIGuessLabel.text = "High!"
		else:
			$AIGuessLabel.text = "Low!"

func _increment_score() -> void:
	score += 1
	$Score.text = "Score: " + str(score)


func _on_ai_selector_item_selected(index: int) -> void:
	brain = (get_parent() as HighLowPlayArea).brains.get_child(index)


func _on_high_low_game_player_game_started(first_card: CardData) -> void:
	if ai_enabled and brain != null:
		guess = brain.generate_guess(null, first_card)
		$AIGuessLabel.visible = true
		if guess == Guess.HIGH:
			$AIGuessLabel.text = "High!"
		else:
			$AIGuessLabel.text = "Low!"
