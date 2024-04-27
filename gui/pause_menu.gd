extends Control


func _process(delta: float) -> void:
	visible = GameManager.game_state == GameManager.GAME_STATE_PAUSED



func _on_resume_button_pressed() -> void:
	GameManager.change_game_state(GameManager.GAME_STATE_PLAYING)


func _on_quit_button_pressed() -> void:
	GameManager.quit()
