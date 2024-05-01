class_name EnemyState
extends Node

var speed: float
var offensive_hitmox_moitorable: bool
var hitbox_monitoring: bool

## Determines which direction to take at an intersection given [param target] as the final destination.
func update_direction(target: Vector2) -> Vector2:
	return Vector2.ZERO


func update_target() -> Vector2:
	return Vector2.ZERO
