extends EnemyController


func _update_hunt_target() -> void:
	_target = muncher.global_position + (muncher.current_direction * _tile_size * 4)
