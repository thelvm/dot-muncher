@tool
extends Node2D

@export var color: Color = Color.DEEP_PINK: set = _set_color
@onready var debug_sprite: Sprite2D = $DebugSprite

func update_position(new_position: Vector2):
	position = new_position

func _set_color(new_color: Color):
	color = new_color
	debug_sprite.modulate = new_color
