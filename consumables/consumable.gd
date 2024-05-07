class_name Consumable
extends Node

@export var point_value: int


func _on_player_collision(_area: Area2D) -> void:
	GameManager.score_points(point_value)
	queue_free()
