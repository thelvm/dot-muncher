class_name Dot extends Node2D

static var dots_in_level: int = 0


func _ready() -> void:
	dots_in_level += 1


func _on_player_collision(area: Area2D) -> void:
	dots_in_level -= 1
	queue_free()
