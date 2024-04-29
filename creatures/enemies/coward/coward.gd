extends EnemyController

@export var cower_distance: int = 4


func _update_hunt_target() -> void:
	if global_position.distance_to(muncher.global_position) < cower_distance * _tile_size:
		_target = global_position - (muncher.global_position - global_position)
	else:
		_target = muncher.global_position

