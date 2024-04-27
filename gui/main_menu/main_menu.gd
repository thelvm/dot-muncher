extends Control


func _process(_delta: float) -> void:
	visible = GameManager.game_state == GameManager.GAME_STATE_MAIN_MENU


func _on_play_button_pressed() -> void:
	GameManager.change_game_state(GameManager.GAME_STATE_PLAYING)
