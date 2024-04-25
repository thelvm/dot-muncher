extends Node

func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("quit"):
		get_tree().quit()
