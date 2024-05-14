extends Control


func _process(_delta: float) -> void:
	visible = GameManager.current_game_state == GameManager.GameState.PAUSED



func _on_resume_button_pressed() -> void:
	GameManager.unpause()


func _on_quit_button_pressed() -> void:
	GameManager.quit()


func _on_main_menu_button_pressed() -> void:
	GameManager.return_to_main_menu()
