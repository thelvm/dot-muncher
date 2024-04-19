extends Node

func _unhandled_key_input(event):
	if Input.is_action_pressed("quit"):
		get_tree().quit()
