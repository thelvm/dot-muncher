extends Consumable


func _on_player_collision(_area: Area2D) -> void:
	get_tree().call_group("level_manager", "start_panic")
	super._on_player_collision(_area)
