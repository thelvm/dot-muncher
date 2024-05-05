extends Node


func _on_area_entered(_area: Area2D) -> void:
	GameManager.game_over()
