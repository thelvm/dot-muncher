class_name DotConsumable
extends Consumable

static var dots_in_level: int = 0


func _ready() -> void:
	dots_in_level += 1


func _on_player_collision(_area: Area2D) -> void:
	dots_in_level -= 1
	super._on_player_collision(_area)
