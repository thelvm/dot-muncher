extends Node


func _on_area_entered(_area: Area2D) -> void:
	GameManager.change_game_state(GameManager.GAME_STATE_GAME_OVER)
