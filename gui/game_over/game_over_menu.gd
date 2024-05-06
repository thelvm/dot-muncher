extends Control

var display_score: int = 0: set = _set_display_score

@onready var score_value_label: Label = %ScoreValueLabel
@onready var new_highscore_label: Label = %NewHighscoreLabel


func _process(_delta: float) -> void:
	visible = GameManager.game_state == GameManager.GAME_STATE_GAME_OVER


func animate_score() -> void:
	create_tween().tween_property(self, "display_score", GameManager.score, 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func _on_visibility_changed() -> void:
	if visible and score_value_label:
		$AnimationPlayer.play("GameOver")
		new_highscore_label.modulate = Color.TRANSPARENT


func _on_retry_button_pressed() -> void:
	GameManager.start_playing()


func _on_main_menu_button_pressed() -> void:
	GameManager.return_to_main_menu()


func _on_quit_button_pressed() -> void:
	GameManager.quit()


func _set_display_score(new_value: int) -> void:
	score_value_label.text = str(new_value)
	display_score = new_value


func check_if_hisghscore() -> void:
	if GameManager.is_hisghscore:
		new_highscore_label.modulate =  Color.WHITE
