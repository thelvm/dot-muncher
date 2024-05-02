extends Control


func _on_play_button_pressed() -> void:
	GameManager.start_playing()


func _on_quit_button_pressed() -> void:
	GameManager.quit()
