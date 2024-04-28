extends Consumable

signal consumed


func _on_player_collision(_area: Area2D) -> void:
	consumed.emit()
	super._on_player_collision(_area)
