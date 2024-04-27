extends Control

@onready var score_tally_label: Label = %ScoreTally


func _process(_delta: float) -> void:
	visible = GameManager.game_state == GameManager.GAME_STATE_GAME_OVER


func _on_visibility_changed() -> void:
	if visible and score_tally_label:
		score_tally_label.text = "Score: " + str(GameManager.score)


func _on_quit_button_pressed() -> void:
	GameManager.quit()
