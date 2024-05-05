extends Control


func _ready() -> void:
	$AnimationPlayer.play("main_menu")


func _on_play_button_pressed() -> void:
	GameManager.start_playing()


func _on_quit_button_pressed() -> void:
	GameManager.quit()
