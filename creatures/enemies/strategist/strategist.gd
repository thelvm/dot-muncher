extends EnemyController

@export var partner: EnemyController


func _update_hunt_target() -> void:
	_target = muncher.position - (partner.position - muncher.position)
